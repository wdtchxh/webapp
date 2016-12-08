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
#import "EMShareEntity.h"
#import "EMWebViewController.h"
#import "JSBridgeModule.h"
#import <JLRoutes/JLRoutes.h>
#import "MSCustomMenuItem.h"
#import "EMShareEntity+Parameters.h"
#import <commonLib/CommonAppSettings.h>
#import <commonLib/BDKNotifyHUD.h>

@implementation JSBridgeModuleBase

@synthesize bridge = _bridge;

JS_EXPORT_MODULE();

- (NSUInteger)priority {
    return JSBridgeModulePriorityHigh;
}

- (NSString *)moduleSourceFile {
    return [[NSBundle bundleForClass:[self class]] pathForResource:@"EMJSBridge" ofType:@"js"];
}

- (void)attachToJSBridge:(JSBridge *)bridge {
    //复制内容到剪切板
    [self registerCopyWithBridge:bridge];
    //
    [self registerCanOpenURLWithBridge:bridge];
    [self registerShowMenuItemsWithBridge:bridge];
    [self registerShowNotifyWithBridge:bridge];
    //导航控制器pop操作
    [self registerPopWithBridge:bridge];
    //浏览器的goback操作
    [self registerGoBackWithBridge:bridge];
    //直接分享
    [self registerShareWithBridge:bridge];
    //创建一个分享对象  稍后用于分享 比如右上角的分享按钮
    [self registerShareConfigWithBridge:bridge];
    //右上角的搜索按钮 启用禁用设置
    [self registerSearchToggleWithBridge:bridge];
    //route 调用
    [self registerOpenPageWithBridge:bridge];
    //修改 nav的  title
    [self registerUpdateTitleWithBridge:bridge];
    //打开一个新的 webview
    [self registerOpenURLWithBridge:bridge];


}

- (void)registerShowMenuItemsWithBridge:(JSBridge *)bridge {
    
    __weak EMWebViewController *webViewController = (EMWebViewController *)bridge.viewController;
    [self registerHandler:@"showMenuItems" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (![webViewController respondsToSelector:@selector(setMenuItems:)]) {
            return;
        }
        NSDictionary *parameters  = data;
        if ([parameters isKindOfClass:[NSString class]]) {
            NSData *jsondata = [data dataUsingEncoding:NSUTF8StringEncoding];
            NSError *jsonError = nil;
            parameters = [NSJSONSerialization JSONObjectWithData:jsondata options:kNilOptions error:&jsonError];
        }
        NSArray *menuItems = parameters[@"menuItems"];
        webViewController.menuItems = [MSCustomMenuItem itemsWithData:menuItems];
    }];
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
- (void)registerShareWithBridge:(JSBridge *)bridge {
    __weak EMWebViewController *webViewController = (EMWebViewController *)bridge.viewController;
    
    [self registerHandler:@"share" handler:^(id data, WVJBResponseCallback responseCallback) {

        NSDictionary *parameters = (NSDictionary *)data;
        
        if ([webViewController respondsToSelector:@selector(share:)]) {
            EMShareEntity *shareEntity = [EMShareEntity shareEntityWithParameters:parameters];
            [webViewController share:shareEntity];
        }
        
        responseCallback(@{JSResponseErrorCodeKey:@(JSResponseErrorCodeSuccess)});
    }];
}
- (void)registerShareConfigWithBridge:(JSBridge *)bridge {
    __weak EMWebViewController *webViewController = (EMWebViewController *)bridge.viewController;
    [self registerHandler:@"shareConfig" handler:^(id data, WVJBResponseCallback responseCallback) {

        NSDictionary *parameters = (NSDictionary *)data;
        if ([webViewController respondsToSelector:@selector(setIsShareItemEnabled:)]) {
            BOOL showsShare = [parameters[@"shareToggle"] boolValue];
            if ([webViewController respondsToSelector:@selector(setIsShareItemEnabled:)]) {
                [webViewController setIsShareItemEnabled:showsShare];
            }
        }
        
        if ([webViewController respondsToSelector:@selector(setShareEntity:)]) {
            EMShareEntity *shareEntity = [EMShareEntity shareEntityWithParameters:parameters];
            [webViewController setShareEntity:shareEntity];
        }
        
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
- (void)registerSearchToggleWithBridge:(JSBridge *)bridge {
    __weak EMWebViewController *webViewController = (EMWebViewController *)bridge.viewController;
    void (^handler)(id, WVJBResponseCallback) = ^(id data, WVJBResponseCallback responseCallback){
        NSDictionary *parameters = (NSDictionary *)data;
        BOOL showsSearch = [parameters[@"searchToggle"] boolValue];
        if ([webViewController respondsToSelector:@selector(setIsSearchItemEnabled:)]) {
            [webViewController setIsSearchItemEnabled:showsSearch];
        }
        
        responseCallback(@{JSResponseErrorCodeKey:@(JSResponseErrorCodeSuccess)});
    };
    
    [self registerHandler:@"searchConfig" handler:handler];
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
- (void)registerUpdateTitleWithBridge:(JSBridge *)bridge {
    __weak UIViewController *viewController = bridge.viewController;
    void (^handler)(id, WVJBResponseCallback) = ^(id data, WVJBResponseCallback responseCallback){
        NSDictionary *parameters = (NSDictionary *)data;
        NSString *title = parameters[@"title"];
        viewController.title = title;
        responseCallback(@{JSResponseErrorCodeKey:@(JSResponseErrorCodeSuccess)});
    };
    
    [self registerHandler:@"updateTitle" handler:handler];
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
