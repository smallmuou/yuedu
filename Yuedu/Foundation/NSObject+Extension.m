
/*!
 * Copyright (c) 2013,福建星网视易信息系统有限公司
 * All rights reserved.
 
 * @File:       NSObject+Notification.m
 * @Abstract:   通知扩展
 * @History:
 
 -2013-05-16 创建 by xuwf
 */


#import "NSObject+Extension.h"

@implementation NSObject (Notification)
- (void)registerNotify:(NSString* )name selector:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:selector name:name object:nil];
}

- (void)unregisterNotify:(NSString* )name
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:name object:nil];
}

- (void)unregisterAllNotify
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
