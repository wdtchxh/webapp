//
//  EMAppSettings.h
//  EMStock
//
//  Created by ryan on 15/11/5.
//  Copyright © 2015年 flora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSettingsCondition.h"
#import <commonLib/CommonAppSettings.h>

#if __MODULE_SHARE_ENABLED__
    #import <MSAppModuleShare/EMAppShareSettings.h>
#endif /* __MODULE_SHARE_ENABLED__ */

#if __MODULE_WEB_APP_ENABLED__
    #import <MSAppModuleWebApp/MSAppSettingsWebApp.h>
#endif /* __MODULE_WEB_APP_ENABLED__ */

@protocol CommonAppSettings;

@interface EMAppSettings : CommonAppSettings <

#if __MODULE_SHARE_ENABLED__
EMAppShareSettings,
#endif

#if __MODULE_WEB_APP_ENABLED__
MSAppSettingsWebApp,
#endif

NSObject
>

#if __MODULE_SHARE_ENABLED__
@property (nonatomic, strong) EMSocialDefaultConfigurator *shareConfigurator;
@property (nonatomic, strong) NSString *theme; // white or black
@property (nonatomic, assign) NSInteger productID;
#endif /* EMAppShareSettings */

#if __MODULE_WEB_APP_ENABLED__

@property (nonatomic, strong) NSArray *supportsURLSchemes;


//@property (nonatomic,  copy) MSWebAppAuthInfo webAppAuthInfo;
//@property (nonatomic,  copy) MSUserHasZXGHandler userHasZXGHandler;

#endif /* __MODULE_WEB_APP_ENABLED__ */
/**
 *参数的本地化存储
 */
- (void)save;

@end

