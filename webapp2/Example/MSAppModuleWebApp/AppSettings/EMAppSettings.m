//
//  EMAppSettings.m
//  EMStock
//
//  Created by ryan on 15/11/5.
//  Copyright © 2015年 flora. All rights reserved.
//

#import "EMAppSettings.h"


NSString *DefaultVendorConfig();

@interface EMAppSettings() {
    
}

@end

@implementation EMAppSettings


-(NSInteger)productID{
    NSLog(@"appsetting productId");
    return 123;
}



- (NSArray *)supportsURLSchemes {
    return @[@"emstock",@"emlite"];
}
//
//-(MSUserHasZXGHandler)userHasZXGHandler{
//    return ^BOOL(NSInteger code) {
//        return code;
//    };
//}
//
//- (void)save
//{
//    [[NSUserDefaults standardUserDefaults] setObject:@(self.vendorID).stringValue forKey:@"em_vendorId"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//
//}

@end



