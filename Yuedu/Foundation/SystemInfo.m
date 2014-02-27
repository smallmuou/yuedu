//
//  SystemInfo.m
//  wifidisk
//
//  Created by xuwf on 12-11-6.
//  Copyright (c) 2012年 evideo. All rights reserved.
//

#import "SystemInfo.h"

@implementation SystemInfo

+ (uint64_t)getSystemTotalSpace
{
    uint64_t capacity = 0;
    NSError *error = nil;  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];  
    if (dictionary) {
        capacity = [[dictionary objectForKey:NSFileSystemSize] longLongValue];
    } else {
        DLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %d", [error domain], [error code]);
    }
    return capacity;
}

+ (uint64_t)getSystemFreeDiskSpace
{
    uint64_t capacity = 0;
    NSError *error = nil;  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];  
    
    if (dictionary) {
        capacity = [[dictionary objectForKey:NSFileSystemFreeSize] longLongValue];
    } else {  
        DLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %d", [error domain], [error code]);  
    }  
    return capacity;
}

+ (BOOL)isSystemRemainSpace:(uint64_t)size
{
    uint64_t freeSize = [SystemInfo getSystemFreeDiskSpace];
    
    //必须大于512M空间才可使用
    return (freeSize > size && (freeSize-size)>512*1024*1024);
}

+ (float)systemVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

@end
