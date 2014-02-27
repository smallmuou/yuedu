
/*!
 * Copyright (c) 2013,福建星网视易信息系统有限公司
 * All rights reserved.
 
 * @File:       NSObject+Notification.h
 * @Abstract:   通知扩展
 * @History:
 
 -2013-05-16 创建 by xuwf
 */

#import <Foundation/Foundation.h>

#define POST_NOTIFY(__name, __object, __userInfo) [[NSNotificationCenter defaultCenter] postNotificationName:__name object:__object userInfo:__userInfo]

@interface NSObject (Notification)
- (void)registerNotify:(NSString* )name selector:(SEL)selector;
- (void)unregisterNotify:(NSString* )name;
- (void)unregisterAllNotify;
@end
