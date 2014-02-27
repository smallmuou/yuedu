//
//  YDMenuItem.h
//  Yuedu
//
//  Created by xuwf on 13-10-16.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YDMenuItem : NSObject
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSArray* children;
@property (strong, nonatomic) NSObject* data;

- (id)initWithName:(NSString *)name children:(NSArray *)array;
+ (id)dataObjectWithName:(NSString *)name children:(NSArray *)children;

@end
