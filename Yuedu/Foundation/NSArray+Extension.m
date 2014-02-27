//
//  NSArray+Extension.m
//  Yuedu
//
//  Created by xuwf on 13-10-28.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "NSArray+Extension.h"

@implementation NSArray (Extension)
- (id)firstObject {
    if (![self count]) return nil;
    return [self objectAtIndex:0];
}
@end
