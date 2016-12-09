//
//  ymActionWebViewController.m
//  ymActionWebView
//
//  Created by flora on 14-7-3.
//  Copyright (c) 2014年 flora. All rights reserved.
//

#import "EMWebViewController.h"
#import "MSAppModuleWebApp.h"
#import "MSAppSettingsWebApp.h"
#import "EMWebBackView.h"
#import "MSAppSettingsWebApp.h"
#import <JLRoutes/JLRoutes.h>
#import <EMSocialKit/EMSocialSDK.h>
// Bridge
#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>
#import "UIWebView+TS_JavaScriptContext.h"
#import "JSBridgeModule.h"
#import "JSBridge.h"
#import "WebViewJavascriptBridgeProtocol.h"
#import "UIWebView+Context.h"
#import "EMWebErrorView.h"
#import <SDWebImage/UIButton+WebCache.h>


#import <commonLib/MSAppModuleController.h>
//-----//
static NSString *const kNavigaionBarHiddenMetaJS = @"document.getElementsByName('app-navigation-bar-hidden')[0].getAttribute('content')";
static const BOOL kNavigationBarHidden = YES;

@interface EMWebViewController ()
{
    NSInteger navigationBarStatus;// 储存navigationBar显示状态
}

@property (nonatomic, strong) UIView *statusBarBackView;
@property (nonatomic, strong) EMWebBackView *backView; //左上角返回按钮
@property (nonatomic, strong) EMWebErrorView *errorView; //请求失败提示页面
@property (nonatomic, strong, readwrite) UIView<XWebView> *webView;

@property (nonatomic, strong) NSURLRequest *loadRequest;  //当前发出去的request对象 失败后可以用来重复发起
@property (nonatomic, strong) NSURL *loadingURL;

@property (nonatomic, strong) id<WebViewJavascriptBridgeProtocol>bridge;
@property (nonatomic, strong) JSBridge *jsBridge;

@end

@implementation EMWebViewController

- (void)dealloc {
    [self.jsBridge reset];
    self.bridge = nil;
    self.jsBridge = nil;
    [self.webView setUIDelegate:nil];
    self.webView = nil;
    self.backView = nil;
    self.loadingURL = nil;
    self.loadRequest = nil;
}

- (instancetype)initWithRouterParams:(NSDictionary *)params {
    
    NSString *urlString = params[@"url"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    self = [self initWithURL:url];
    
    if (self) {
        NSString *navigationBarHidden = params[@"navigationBarHidden"];
        if (navigationBarHidden.length > 0) {
            navigationBarStatus = [navigationBarHidden integerValue];
        } else {
            navigationBarStatus = 0;
        }
    }
    
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL {
    return [self initWithRequest:[NSURLRequest requestWithURL:URL]];
}

- (instancetype)init {
    self = [self initWithRequest:nil];
    if (self) {
    }
    return self;
}

#pragma mark life cycle
- (instancetype)initWithRequest:(NSURLRequest *)request {
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
            self.edgesForExtendedLayout = UIRectEdgeAll;
        }
        self.synchronizeDocumentTitle = YES;
        [self setShowsCloseButton:YES];
        
        if (request) {
            [self openRequest:request];
        }
    }
    
    
    return self;
}

- (void)setShowsCloseButton:(BOOL)showsCloseButton {
    _showsCloseButton = showsCloseButton;
    if (_showsCloseButton) {
        [self loadBackView];
    } else {
        [self unloadBackView];
    }
}

/**
 * 子类可通过复现当前类，修改返回方案
 */
- (void)loadBackView {
    //生成导航条返回按键
    self.backView = [[EMWebBackView alloc] initWithParamSupportClose:YES];
    [self.backView addTarget:self backAction:@selector(doBack) closeAction:@selector(doClose) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.backView];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)unloadBackView {
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpWebView];
    
    
    if (nil != self.loadRequest) {
        [self.webView x_loadRequest:self.loadRequest];
    }
    self.backView.supportClose = [self supportClose];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self changeNavigationBarStatusAnimated:animated];

    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    navigationBarStatus = self.navigationController.navigationBarHidden;
    [self showNetworkActivityIndicator:NO];
    
}

#pragma mark - Create UIWebView or WKWebView
- (void)setUpWebView {
    // [[JSBridge sharedBridge] attachToBridge:self.bridge];调用的时机不一样
    // WKWebView通过userContentController 注入脚本
    // UIWebView在获取JSContext的时候注入脚本
    
    if (NSClassFromString(@"WKWebView")) {
        [WKWebViewJavascriptBridge enableLogging];
        
        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController = userContentController;
        WKWebView *wkWebView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
        wkWebView.UIDelegate = self; // 设置WKUIDelegate代理
        wkWebView.navigationDelegate = self; // 设置WKNavigationDelegate代理
        [self.view addSubview:wkWebView];
        _webView = (UIView<XWebView> *)wkWebView;//
        
        [self bridgeWithWebView];
        [self.jsBridge attachToBridge:self.bridge];
        
    } else {
        [WebViewJavascriptBridge enableLogging];
        
        UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        webView.opaque = NO;
        webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        webView.scrollView.clipsToBounds = YES;
        webView.delegate = self;
        webView.scalesPageToFit = YES;
        [self.view addSubview:webView];
        _webView = (UIView<XWebView> *)webView;
        
        [self bridgeWithWebView];
    }
}
//create bridge and jsBridge
- (void)bridgeWithWebView {
    if (!self.bridge) {
        if ([_webView isKindOfClass:[WKWebView class]]) {
            self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:(WKWebView *)_webView];
        } else {
            self.bridge = [WebViewJavascriptBridge bridgeForWebView:(UIWebView *)_webView];
        }
        
        [self.bridge setWebViewDelegate:self];
        
        self.jsBridge = [JSBridge new];
        self.jsBridge.javaScriptBridge = self.bridge;
        self.jsBridge.viewController = self;
        self.jsBridge.webView = _webView;
    }
}

- (void)showErrorView {
    if (!self.errorView) {
        self.errorView = [[EMWebErrorView alloc] initWithFrame:self.view.bounds];
        [self.webView addSubview:self.errorView];
        
        __weak __typeof(self) weakSelf = self;
        __weak __typeof(UIView<XWebView> *) webView = self.webView;
        self.errorView.tapBlock = ^() {
            [weakSelf hideErrorView];
            [webView x_loadRequest:weakSelf.loadRequest];
        };
    }
    self.errorView.frame = self.webView.bounds;
    self.errorView.hidden = NO;
}

- (void)hideErrorView {
    self.errorView.hidden = YES;
}

#pragma mark - Override   是否显示返回按钮
- (BOOL)supportClose {
    return ([self.navigationController.viewControllers count] > 1 || self.presentingViewController) ? YES : NO;
}

- (void)changeNavigationBarStatusAnimated:(BOOL)animated {
    if (navigationBarStatus != -1) {
        [self.navigationController setNavigationBarHidden:navigationBarStatus animated:NO];
    }
}

- (void)reloadTitle {        //提取页面的标题作为当前controller的标题
    __weak typeof(self) weakSelf = self;
    [self getRemoteTitleWithHandler:^(NSString *title) {
        if (title && title.length) {
            weakSelf.title = title;
        }
    }];
}

- (void)getRemoteTitleWithHandler:(nullable void (^)(NSString *title))handler {
    [self.webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable rs, NSError *_Nullable error) {
        handler(rs);
    }];
}

// 显示高度为20的view盖住webview
- (void)showTopStatusBarViewWithNavigationBarHidden:(BOOL)navigationBarHidden {
    if (navigationBarHidden) {
        CGRect topBarRect = self.view.bounds;
        topBarRect.size.height = 20;
        if (self.statusBarBackView == nil) {
            self.statusBarBackView = [[UIView alloc] initWithFrame:topBarRect];
            self.statusBarBackView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        } else {
            self.statusBarBackView.frame = topBarRect;
        }
        [self.view addSubview:self.statusBarBackView];
    } else {
        [self.statusBarBackView removeFromSuperview];
    }
}

- (void)updateWebViewPropertiesWithNavigationBarHidden:(BOOL)navigationBarHidden {
    if (navigationBarHidden) {
        self.webView.opaque = YES;
        self.webView.scrollView.bounces = NO;
    } else {
        self.webView.opaque = NO;
        self.webView.scrollView.bounces = YES;
    }
}

#pragma mark -
#pragma mark UIWebView delegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self showNetworkActivityIndicator:NO];
    NSLog(@"%zd %@", error.code,[error localizedDescription]);
    
    if([error code] == NSURLErrorCancelled /* -999 */) {
        [self showErrorView];
    } else if (error.code == NSURLErrorServerCertificateUntrusted /* -1202 */) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请确认网页的证书"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"确定", nil];
        [alert show];
    } else {
        [self showErrorView];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    self.errorView.hidden=YES;
    MSAppModuleWebApp *webApp = [appModuleManager appModuleWithModuleName:NSStringFromClass([MSAppModuleWebApp class])];
    id<MSAppSettingsWebApp> settings = (id<MSAppSettingsWebApp>)[webApp moduleSettings];
    
    NSURL *url = request.URL;
    NSString *lowercaseScheme = [[url scheme] lowercaseString];
                                 
    if ([lowercaseScheme isEqualToString:@"tel"] ||
        [lowercaseScheme isEqualToString:@"telprompt"] ||
        [lowercaseScheme isEqualToString:@"sms"]) {
        return YES;
    } else if ([[settings supportsURLSchemes] containsObject:url.scheme]) {
        [JLRoutes routeURL:url];
        return NO;
    } else if ([lowercaseScheme hasPrefix:@"http"] ||
        [lowercaseScheme hasPrefix:@"file"]
        ) {
        self.loadRequest = request;
    }
    
    return YES;
}

// 使用hash跳转不会进入- (void)webViewDidFinishLoad:(UIWebView *)webView
// 所以在里面-shouldStartLoadWithRequest 中调用[self showNetworkActivityIndicator:YES];
// Indicator 无法再-webViewDidFinishLoad中停止
- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    NSURL *url = [self.loadRequest URL];
    
    if ([[[url scheme] lowercaseString] hasPrefix:@"http"] ||
        [[[url scheme] lowercaseString] hasPrefix:@"file"]
        ) {
        [self showNetworkActivityIndicator:YES];
    }
    
}

- (void)webView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext *)ctx {
    self.jsBridge.javascriptContext = ctx;
    [self.jsBridge attachToBridge:self.bridge];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self showNetworkActivityIndicator:NO];
    
    if (self.synchronizeDocumentTitle) {
        [self reloadTitle];
    }
    
    self.backView.showGoBack = self.webView.canGoBack;
    [self updateNavigationBarByMeta];
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [self reloadTitle];
}

#pragma mark WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}
#pragma mark WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    completionHandler(YES);
}

#pragma mark -
- (void)updateNavigationBarByMeta {
    NSString *js = kNavigaionBarHiddenMetaJS;
    
    __block BOOL hide = NO;
    __weak typeof(self) weakSelf = self;
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable hiddenObject, NSError *_Nullable error) {
        hide = [[hiddenObject lowercaseString] isEqualToString:@"yes"];
        [weakSelf _hideNavigationBar:hide];
    }];
}

- (void)_hideNavigationBar:(BOOL)hide {
    BOOL changed = NO;
    if (hide
        ) {
        if (!self.navigationController.navigationBarHidden) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController setNavigationBarHidden:YES animated:YES];
            });
            changed = YES;
        }
        navigationBarStatus = kNavigationBarHidden;
        [self showTopStatusBarViewWithNavigationBarHidden:YES];
        [self updateWebViewPropertiesWithNavigationBarHidden:YES];
    } else {
        if (self.navigationController.navigationBarHidden) {
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            changed = YES;
        }
        navigationBarStatus = -1;
        [self showTopStatusBarViewWithNavigationBarHidden:NO];
        [self updateWebViewPropertiesWithNavigationBarHidden:NO];
    }
    
    if (changed) {
    }
}

#pragma mark -
#pragma mark Public
- (NSURL *)URL {
    return self.loadingURL ? self.loadingURL : self.webView.URL;
}

- (void)openURL:(NSURL *)URL {
    self.loadingURL = URL;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [self openRequest:request];
}

- (void)openRequest:(NSURLRequest *)request {
    self.loadRequest = request;
    
    if ([self isViewLoaded]) {
        if (nil != request) {
            [self.webView x_loadRequest:request];
        } else {
            [self.webView stopLoading];
        }
    }
}

- (void)openHTMLString:(NSString *)htmlString baseURL:(NSURL *)baseUrl {
    [_webView x_loadHTMLString:htmlString baseURL:baseUrl];
}



#pragma mark -
#pragma mark actions

/**按键按键处理步骤
 * 1、如果网页可返回，返回网页
 * 2、如果网页不可返回且支持回退功能，回退上一页
 * 3、如果网页不可返回且不支持回退功能，重置当前backView状态
 */
- (void)doBack {
    if ([self.webView canGoBack]) {
        [self.webView x_goBack];
        [self.backView goBack];
    } else {
        if (self.backView.supportClose) {
            [self doClose];
        } else {
            self.backView.showGoBack = self.webView.canGoBack;
        }
    }
}

/**回退到上一页，pop或dismiss
 */
- (void)doClose {
    if (self.navigationController && [self.navigationController.viewControllers count] > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - KeyCommands
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (NSArray *)keyCommands {
    NSMutableArray *keyCommands = [NSMutableArray array];;
    NSArray *superKeyCommands = [super keyCommands];
    if (superKeyCommands == nil) {
    } else {
        [keyCommands addObjectsFromArray:superKeyCommands];
    }
    [keyCommands addObject:[UIKeyCommand keyCommandWithInput:@"r" modifierFlags:UIKeyModifierCommand action:@selector(commandRPressed:)]];
    return keyCommands;
}

- (void)commandRPressed:(id)sender {
    [_webView x_reload];
}

- (void)showNetworkActivityIndicator:(BOOL)visible {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:visible];
}

- (void)doRefresh {
    [self hideErrorView];
    if ([_webView canGoBack]) {
        [_webView x_reload];
    } else {
        if (nil != self.loadRequest) {
            [self.webView x_loadRequest:self.loadRequest];
        }
    }
}


@end

