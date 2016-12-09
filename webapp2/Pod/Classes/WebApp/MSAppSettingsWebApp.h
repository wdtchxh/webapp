//
//  MSAppSettingsWebApp.h
//  Pods
//
//  Created by ryan on 3/9/16.
//
//

#import <Foundation/Foundation.h>
#import <commonLib/MSAppModule.h>

@protocol MSAppSettingsWebApp <CommonAppSettings>

//@property (nonatomic, strong) NSString *theme;//当前主题标记 多主题app适用
@property (nonatomic, strong) NSArray *supportsURLSchemes;//是否支持应用间跳转


@end
