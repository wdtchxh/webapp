//
//  UIWebView+JSExtend.m
//  EMStock
//
//  Created by ryan on 15/8/27.
//  Copyright (c) 2015年 flora. All rights reserved.
//

#import "UIWebView+JSExtend.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "MSAppSettingsWebApp.h"
#import "NSDictionary+JSONString.h"
#import <commonLib/MSAppModuleController.h>
#import <commonLib/CommonAppSettings.h>


@implementation UIWebView (JSExtend)

- (void)attachExtendActionsWithContext:(JSContext *)context {

    __weak __typeof (self)weakSelf = self;
    
    JSValue *goods = [context objectForKeyedSubscript:@"goods"];
    if ([goods isUndefined] || ![goods toDictionary]){
        return;
    }

    BOOL (^CanOpenURL)(NSString *, NSString *) = ^BOOL(NSString *urlString, NSString *callback) {
        BOOL rs = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]];
        NSString* string = [NSString stringWithFormat:@"%@(%d);",callback,rs];
        [weakSelf stringByEvaluatingJavaScriptFromString:string];

        return rs;
    };
    
    [goods setObject:CanOpenURL forKeyedSubscript:@"canOpenURL"];
    
    
    id<MSAppSettingsWebApp> settings = (id<MSAppSettingsWebApp>)[CommonAppSettings appSettings];

#if 1
    
    BOOL (^IsZxg)(NSString *, NSString *callback) = ^BOOL(NSString *stockId, NSString *callback) {
        id<MSAppSettingsWebApp>appSettings = (id<MSAppSettingsWebApp>)[CommonAppSettings appSettings];
        return YES;
    };

    

#endif
    
}

@end
