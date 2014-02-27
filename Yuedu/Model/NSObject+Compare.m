
/*!
 * Copyright (c) 2013,福建星网视易信息系统有限公司
 * All rights reserved.
 
 * @File:       NSObject+Compare.m
 * @Abstract:   对象比较
 * @History:
 
 -2013-05-14 创建 by xuwf
 */

#import "NSObject+Compare.h"

@implementation NSObject (Compare)
- (NSComparisonResult )compareWithObject:(id)aObject {
    return NSOrderedAscending;
}
- (NSComparisonResult )compareValue:(id)value forKey:(NSString* )key {
    NSSortDescriptor* sd = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    return [sd compareObject:[self valueForKey:key] toObject:value];
}
@end

@implementation ArticleItem (Compare)
- (NSComparisonResult )compareWithObject:(id)aObject {
    ArticleItem* item  = (ArticleItem* )aObject;
    if (self.sid > item.sid) {
        return NSOrderedDescending;
    } else if (self.sid == item.sid) {
        return NSOrderedSame;
    } else {
        return NSOrderedAscending;
    }
}
@end

