
/*!
 * Copyright (c) 2013,福建星网视易信息系统有限公司
 * All rights reserved.
 
 * @File:       Macro.h
 * @Abstract:   宏定义
 * @History:
 
 -2013-06-14 创建 by xuwf
 */

#define USER_CONFIG(__key) [[NSUserDefaults standardUserDefaults] objectForKey:__key]
#define USER_SET_CONFIG(__key, __value) [[NSUserDefaults standardUserDefaults] setObject:__value forKey:__key]

/* KVO */
#define KVO_WILLCHANGE(__key)   [self willChangeValueForKey:__key]
#define KVO_DIDCHANGE(__key)    [self didChangeValueForKey:__key]
#define KVO_CHANGE(__key)       [self willChangeValueForKey:__key];[self didChangeValueForKey:__key]


/* Device */
#define isIPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

/* Release */
#if __has_feature(objc_arc)
#define SARELEASE(__obj) \
    do {\
        __obj = nil;\
    }while(0)

#define SARELEASE_TIMER(__timer) \
    do {\
        [__timer invalidate];\
        __timer = nil;\
    }while(0)
#else
#define SARELEASE(__obj) \
    do {\
        [__obj release];\
        __obj = nil;\
    }while(0)

#define SARELEASE_TIMER(__timer) \
    do {\
        [__timer invalidate];\
        [__timer release];\
        __timer = nil;\
    }while(0)
#endif

/* IOS版本 */
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

/* Color */
#define COLOR(R, G, B, A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

/* Constants */
#define DEVICE_LIST_CELL_ROW_HEIGHT (50)

#define SHOW_NETWORK_INDICATOR() [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES]

#define HIDE_NETWORK_INDICATOR() [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO]

#define IMG(__name) [UIImage imageNamed:__name]
#define STRING(__str) __str?[NSString stringWithUTF8String:__str]:nil
#define ARRAY(__obj1, ...) [NSArray arrayWithObjects:__obj1, ##__VA_ARGS__, nil]
#define VERSION() [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]

