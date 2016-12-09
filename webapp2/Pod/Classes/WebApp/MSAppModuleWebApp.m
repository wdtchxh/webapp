//
//  MSAppModuleWebApp.m
//  Pods
//
//  Created by ryan on 3/9/16.
//
//

#import "MSAppModuleWebApp.h"
#import "MSAppSettingsWebApp.h"
#import <JLRoutes/JLRoutes.h>
#import <UIViewController+Routes.h>
#import "EMWebViewController.h"
#import "MSActiveControllerFinder.h"

@implementation MSAppModuleWebApp

- (void)moduleDidLoad:(id<MSAppSettingsWebApp>)info {
    [super moduleDidLoad:info];
}



- (void)moduleRegisterRoutes:(JLRoutes *)route {
    [self registerWeb];
    [self registerGoBack];
}

- (void)moduleUnregisterRoutes:(JLRoutes *)route {
}


- (void)registerWeb {
    [JLRoutes addRoute:@"webapp" handler:^BOOL(NSDictionary *parameters) {
        UINavigationController *navController = [MSActiveControllerFinder finder].activeNavigationController();
        [MSActiveControllerFinder finder].resetStatus();
        [navController pushViewControllerClass:NSClassFromString(@"EMWebViewController") params:parameters];
        return YES;
    }];
}

- (void)registerGoBack {
    BOOL (^completion)(NSDictionary *) = ^BOOL(NSDictionary *parameters) {
        EMWebViewController *webViewController = (EMWebViewController *)[MSActiveControllerFinder finder].activeTopController();
        if ([webViewController respondsToSelector:@selector(webView)]) {
            [[webViewController webView] x_goBack];
        }
        return YES;
    };
    
    [JLRoutes addRoutes:@[@"goBack", @"goback"] handler:completion];
}


@end
