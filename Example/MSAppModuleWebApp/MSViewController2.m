//
//  MSViewController.m
//  MSAppModuleWebApp
//
//  Created by Ryan Wang on 03/09/2016.
//  Copyright (c) 2016 Ryan Wang. All rights reserved.
//

#import "MSViewController2.h"
#import "EMWebViewController.h"
#import <commonLib/MSCoreFileManager.h>
#import <commonLib/BDKNotifyHUD.h>
#import <JLRoutes/JLRoutes.h>
@interface MSViewController2 ()
@end

@implementation MSViewController2

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        NSLog(@"initWithCoder");
    }
    return self;
}

-(void)loadView{
    [super loadView];
    NSLog(@"loadView");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    
    //NSString *path = MSPathForBundleResource([NSBundle mainBundle], @"");
    
}

- (IBAction)open:(id)sender {
    
   // [BDKNotifyHUD showNotifHUDWithText:@"aadsfasdfasd"];
    
   // NSURL *url = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html"];
    
    NSURL *url =[NSURL URLWithString:@"web?url=http://ms.emoney.cn/html/dujia/77/154344.html"];
    //NSURL *url =[NSURL URLWithString:@"http://www.yummy77.com/"];
//    EMWebViewController *webViewController = [[EMWebViewController alloc] initWithURL:url];
//    [self.navigationController pushViewController:webViewController animated:YES];
    //[JLRoutes routeURL:[NSURL URLWithString:goToWeb([cm.item.htmlUrl URLEncodedString])]];
    [JLRoutes routeURL:url];
}

@end
