//
//  JSBridgeModuleJSContext.m
//  Pods
//
//  Created by ryan on 5/5/16.
//
//

#import "JSBridgeModuleJSContext.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <commonLib/CommonAppSettings.h>
#import "NSDictionary+JSONString.h"
#import "JSBridge.h"
#import "UIWebView+TS_JavaScriptContext.h"
#import "MSAppSettingsWebApp.h"
@implementation JSBridgeModuleJSContext

JS_EXPORT_MODULE();

- (NSUInteger)priority {
    return JSBridgeModulePriorityLow;
}

//- (void)attachToJSBridge:(JSBridge *)bridge {
//}

@end
