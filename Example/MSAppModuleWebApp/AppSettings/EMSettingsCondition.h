//
//  EMSettingsCondition.h
//  EMStock
//
//  Created by ryan on 3/9/16.
//  Copyright © 2016 flora. All rights reserved.
//

#ifndef __SETTINGS_CONDITION_H__
#define __SETTINGS_CONDITION_H__

#if __has_include(<MSAppModuleShare/EMAppShareSettings.h>)

#define __MODULE_SHARE_ENABLED__ 1

#endif


#if __has_include(<MSAppModuleWebApp/MSAppSettingsWebApp.h>)

#define __MODULE_WEB_APP_ENABLED__ 1

#endif

#endif
