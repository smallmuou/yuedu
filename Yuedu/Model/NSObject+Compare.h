
/*!
 * Copyright (c) 2013,福建星网视易信息系统有限公司
 * All rights reserved.
 
 * @File:       NSObject+Compare.h
 * @Abstract:   对象比较
 * @History:
 
 -2013-05-14 创建 by xuwf
 */

#import <Foundation/Foundation.h>

@interface NSObject (Compare)
- (NSComparisonResult )compareWithObject:(id)aObject;
- (NSComparisonResult )compareValue:(id)value forKey:(NSString* )key;
@end
