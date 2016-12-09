//1、加载网页
//2、可通过设置synchronizeDocumentTitle = yes，同步在导航栏显示当前页面的标题，默认是yes
//3、可通过各接口加载url、request、htmlstring
//4、支持js事件
//5、处理tel以及sms事件
//6、自定义返回控件，可控制页面内返回事件。用户点击返回按键执行网页后退一次后，增加关闭按键，可通过关闭按键退出当前controller
//

#import <UIKit/UIKit.h>
#import "UIViewController+Routes.h"

#import "XWebView.h"
#import "WKWebView+XWebView.h"
#import "UIWebView+XWebView.h"

@class MSMenuItemData,EMWebBackView,EMShareEntity;
@protocol UIViewControllerRouter,XWebView;



@interface EMWebViewController : UIViewController<UIWebViewDelegate, WKUIDelegate, WKNavigationDelegate,UIViewControllerRouter>
{
    
}

@property (nonatomic, assign) BOOL synchronizeDocumentTitle;//是否同步页面document的title，default is yes
@property (nonatomic, strong, readonly) UIView<XWebView> *webView;
@property (nonatomic, assign, getter = isCloseButtonShown) BOOL showsCloseButton; // Default YES

// 通过JLRoutes跳转的时候 可附加eventAttributes 会传入统计中去
@property (nonatomic, strong) NSDictionary *eventAttributes;

- (instancetype)initWithURL:(NSURL *)URL;
- (instancetype)initWithRequest:(NSURLRequest *)request;
- (NSURL *)URL;
- (void)openURL:(NSURL *)URL;
- (void)openRequest:(NSURLRequest *)request;
- (void)openHTMLString:(NSString *)htmlString baseURL:(NSURL *)baseUrl;
- (void)doRefresh;
- (void)share:(EMShareEntity *)shareEntity;

@end
