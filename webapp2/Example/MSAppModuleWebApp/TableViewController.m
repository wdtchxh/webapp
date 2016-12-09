//
//  MSViewController.m
//  MSAppModuleWebApp
//
//  Created by Ryan Wang on 03/09/2016.
//  Copyright (c) 2016 Ryan Wang. All rights reserved.
//

#import "TableViewController.h"
#import "EMWebViewController.h"
#import <commonLib/MSCoreFileManager.h>
#import <commonLib/BDKNotifyHUD.h>
#import <JLRoutes/JLRoutes.h>
@interface TableViewController ()
@end
static NSDictionary *tableItem;

@implementation TableViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    tableItem = @{@"0":@"test--index",
                  @"1":@"打开一个新的webview--newWebView",
                  @"2":@"copy内容--copy",
                  @"3":@"设置导航右上角按钮--rightItem",
                  @"4":@"显示一个消息 从此远离alert--message",
                  @"5":@"导航控制器回pop--navpop",
                  @"6":@"route跳转--route",
                  };
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return tableItem.allKeys.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentify =@"cellIDentify";
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (!cell) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    
    cell.textLabel.text=[tableItem valueForKey:@(indexPath.row).stringValue];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *str = [tableItem valueForKey:@(indexPath.row).stringValue];
    NSArray *array = [str componentsSeparatedByString:@"--"];
    NSString *pageName = array[1];
    [self open:pageName];
}
- (void)open:(NSString *)pageName {
    
    //http://ms.emoney.cn/html/js/SinglePage.js?v=4
   // [BDKNotifyHUD showNotifHUDWithText:@"aadsfasdfasd"];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:pageName withExtension:@"html"];
    NSString *str=[NSString stringWithFormat:@"webapp?url=%@",url.absoluteString];
    url =[NSURL URLWithString:str];
    //NSURL *url =[NSURL URLWithString:@"web?url=http://ms.emoney.cn/html/dujia/77/154344.html"];
    //NSURL *url =[NSURL URLWithString:@"http://www.yummy77.com/"];
//    EMWebViewController *webViewController = [[EMWebViewController alloc] initWithURL:url];
//    [self.navigationController pushViewController:webViewController animated:YES];
    //[JLRoutes routeURL:[NSURL URLWithString:goToWeb([cm.item.htmlUrl URLEncodedString])]];
    [JLRoutes routeURL:url];
}

@end
