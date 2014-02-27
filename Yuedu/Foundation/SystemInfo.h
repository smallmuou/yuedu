//
//  SystemInfo.h
//  wifidisk
//
//  Created by xuwf on 12-11-6.
//  Copyright (c) 2012年 evideo. All rights reserved.
//

#import <Foundation/Foundation.h>


#define IOS_OVER_6()     ([SystemInfo systemVersion] >= 6.0)

#define IS_IPHONE5  ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )                  //当前设备是iphone5

#define SUPPORT_IOS6  (__IPHONE_OS_VERSION_MAX_ALLOWED >= 60000)

@interface SystemInfo : NSObject

+ (uint64_t)getSystemTotalSpace;
+ (uint64_t)getSystemFreeDiskSpace;
+ (float)systemVersion;
+ (BOOL)isSystemRemainSpace:(uint64_t)size;

@end
