//
//  JLRoutes+WebApp.m
//  Pods
//
//  Created by ryan on 3/17/16.
//
//

#import "JLRoutes+WebApp.h"
//#import <BDKNotifyHUD.h>
#import <UIViewController+Routes.h>

#import "MSActiveControllerFinder.h"
#import "EMWebViewController.h"
#import "XWebView.h"

@implementation JLRoutes (WebApp)

- (void)registerRoutesForWebApp {
    [self registerWeb];
    [self registerGoBack];
}


- (void)registerWeb {
    [self addRoute:@"web" handler:^BOOL(NSDictionary *parameters) {
        UINavigationController *navController = [MSActiveControllerFinder finder].activeNavigationController();
        [MSActiveControllerFinder finder].resetStatus();
        [navController pushViewControllerClass:NSClassFromString(@"EMWebViewController") params:parameters];
        return YES;
    }];
}

/**
 *  注册网页返回`goBack`
 */
- (void)registerGoBack {
    // 网页返回
    // 保证WebViewController 有webview属性
    BOOL (^completion)(NSDictionary *) = ^BOOL(NSDictionary *parameters) {
        EMWebViewController *webViewController = (EMWebViewController *)[MSActiveControllerFinder finder].activeTopController();
        if ([webViewController respondsToSelector:@selector(webView)]) {
            [[webViewController webView] x_goBack];
        }
        return YES;
    };
    
    [self addRoutes:@[@"goBack", @"goback"] handler:completion];
}


@end
