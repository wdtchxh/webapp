//
//  MSAppDelegate.m
//  MSAppModuleWebApp
//
//  Created by Ryan Wang on 03/09/2016.
//  Copyright (c) 2016 Ryan Wang. All rights reserved.
//

#import "MSAppDelegate.h"
#import "EMAppSettings.h"
#import <MSAppModuleWebApp.h>
#import <commonLib/MSAppModuleController.h>
@implementation MSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    EMAppSettings *appSettings = [EMAppSettings appSettings];
    [MSAppModuleController appModuleControllerWithSettings:appSettings];
    //
    [appModuleManager addModule:[MSAppModuleWebApp new]];

    NSLog(@"didFinishLaunchingWithOptions");
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [appModuleManager openURL:url sourceApplication:sourceApplication annotation:annotation navigation:nil];
    
    return YES;
}
@end
