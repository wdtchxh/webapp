//
//  JSBridgeModuleBase.m
//  Pods
//
//  Created by ryan on 5/4/16.
//
//

#import "JSBridgeModuleBase.h"
#import "JSBridge.h"
#import "MSAppSettingsWebApp.h"
#import "EMWebViewController.h"
#import "JSBridgeModule.h"
#import <JLRoutes/JLRoutes.h>
#import <commonLib/CommonAppSettings.h>
#import <commonLib/BDKNotifyHUD.h>

@implementation JSBridgeModuleBase

@synthesize bridge = _bridge;

JS_EXPORT_MODULE();

- (NSUInteger)priority {
    return JSBridgeModulePriorityHigh;
}
//js api
- (NSString *)moduleSourceFile {
    return [[NSBundle bundleForClass:[self class]] pathForResource:@"EMJSBridge" ofType:@"js"];
}
//oc api
- (void)attachToJSBridge:(JSBridge *)bridge {
    //复制内容到剪切板
    [self registerCopyWithBridge:bridge];
    //[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]
    [self registerCanOpenURLWithBridge:bridge];
    //显示一个弹窗
    [self registerShowNotifyWithBridge:bridge];
    //导航控制器pop操作
    [self registerPopWithBridge:bridge];
    //浏览器的goback操作
    [self registerGoBackWithBridge:bridge];
    //route 调用
    [self registerOpenPageWithBridge:bridge];
    //打开一个新的 webview
    [self registerOpenURLWithBridge:bridge];


}


- (void)registerCanOpenURLWithBridge:(JSBridge *)bridge {
    [self registerHandler:@"canOpenURL" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *parameters = (NSDictionary *)data;
        // @params: {appurl:"emstock://"}
        NSString *url = parameters[@"appurl"];
        
        BOOL canopen = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]];
        
        responseCallback(@{JSResponseErrorCodeKey:@(JSResponseErrorCodeSuccess),
                           JSResponseErrorDataKey:@(canopen)});
    }];
}
- (void)registerCopyWithBridge:(JSBridge *)bridge {
    [self registerHandler:@"copy" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *parameters = (NSDictionary *)data;
        NSString *text = parameters[@"text"];
        UIPasteboard *p = [UIPasteboard generalPasteboard];
        
        [p setString:text];
        responseCallback(@{JSResponseErrorCodeKey:@(JSResponseErrorCodeSuccess)});
    }];
}
- (void)registerShowNotifyWithBridge:(JSBridge *)bridge {
    [self registerHandler:@"showNotify" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *message = data[@"message"];
        [BDKNotifyHUD showNotifHUDWithText:message];
        responseCallback(@{JSResponseErrorCodeKey:@(JSResponseErrorCodeSuccess)});
    }];
}
- (void)registerPopWithBridge:(JSBridge *)bridge {
    __weak EMWebViewController *webViewController = (EMWebViewController *)bridge.viewController;

    void (^handler)(id, WVJBResponseCallback) = ^(id data, WVJBResponseCallback responseCallback){
        NSDictionary *parameters = (NSDictionary *)data;
        BOOL animated = YES;
        if (parameters[@"animated"]) {
            animated = [parameters[@"animated"] boolValue];
        }
        [webViewController.navigationController popViewControllerAnimated:animated];
        
        responseCallback(@{JSResponseErrorCodeKey:@(JSResponseErrorCodeSuccess)});
    };
    
    
    [self registerHandler:@"close" handler:handler];
    
}
- (void)registerGoBackWithBridge:(JSBridge *)bridge {
    __weak EMWebViewController *webViewController = (EMWebViewController *)bridge.viewController;
    void (^handler)(id, WVJBResponseCallback) = ^(id data, WVJBResponseCallback responseCallback){
        
        if ([webViewController respondsToSelector:@selector(webView)]) {
            [[webViewController webView] x_goBack];
        }
        
        responseCallback(@{JSResponseErrorCodeKey:@(JSResponseErrorCodeSuccess)});
    };
    
    [self registerHandler:@"goback" handler:handler];
    
}
- (void)registerOpenPageWithBridge:(JSBridge *)bridge {
    void (^handler)(id, WVJBResponseCallback) = ^(id data, WVJBResponseCallback responseCallback){
        NSDictionary *parameters = (NSDictionary *)data;
        //其实web也可以 从 页面传递过来
        [JLRoutes routeURL:[NSURL URLWithString:@"web"] withParameters:parameters];
        responseCallback(@{JSResponseErrorCodeKey:@(JSResponseErrorCodeSuccess)});
    };
    
    [self registerHandler:@"page" handler:handler];
    
}
- (void)registerOpenURLWithBridge:(JSBridge *)bridge {
    __weak UIViewController *viewController = bridge.viewController;
    void (^handler)(id, WVJBResponseCallback) = ^(id data, WVJBResponseCallback responseCallback){
        NSDictionary *parameters = (NSDictionary *)data;
        EMWebViewController *webViewController = [[EMWebViewController alloc] initWithRouterParams:parameters];
        [viewController.navigationController pushViewController:webViewController animated:YES];
        responseCallback(@{JSResponseErrorCodeKey:@(JSResponseErrorCodeSuccess)});
    };
    [self registerHandler:@"web" handler:handler];
}

@end
