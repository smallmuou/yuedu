//
//  YDAppDelegate.h
//  Yuedu
//
//  Created by xuwf on 13-10-15.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import <UIKit/UIKit.h>

#define __appDelegate ((YDAppDelegate* )[[UIApplication sharedApplication] delegate])

extern NSString* SettingsAutoDownloadKey;
extern NSString* SettingsAutoPlayKey;
extern NSString* SettingsSleepTimerKey;


@class MMDrawerController;

@interface YDAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) MMDrawerController* drawerController;
@end
