
/*!
 * Copyright (c) 2013,福建星网视易信息系统有限公司
 * All rights reserved.
 
 * @File:       DataCenter.h
 * @Abstract:   数据中心
 * @History:
 
 -2013-09-03 创建 by xuwf
 */

#import <Foundation/Foundation.h>

@interface DataCenter : NSObject
- (void)registerForKey:(NSString* )key;
- (void)registerForKeysFromArray:(NSArray* )keys;

- (void)unregisterForKey:(NSString* )key;
- (void)unregisterAllKeys;


- (void)addItem:(id)item forKey:(NSString* )key clear:(BOOL)clear;
- (void)addItemsFromArray:(NSArray* )array forKey:(NSString* )key clear:(BOOL)clear;

- (void)insertItem:(id)item forKey:(NSString* )key;

- (void)updateItem:(id)item forKey:(NSString* )key update:(BOOL)update;
- (void)updateItemsFromArray:(NSArray* )array forKey:(NSString* )key;

- (void)removeItem:(id)item forKey:(NSString* )key;
- (void)removeItemsFromArray:(NSArray* )array forKey:(NSString* )key;
- (void)removeAllItemsForKey:(NSString* )key;
- (void)removeAllItems;
/*!
 dataForType
 @param key   数据Key
 @param flag    是否copy
 @return 返回对应的数据
 */

- (NSArray* )dataForKey:(NSString* )key;

/*!
 itemsForType:value:forKey
 @param     key   数据Key
 @param     value   条件值
 @param     name     键（见对应的item定义）
 
 根据给定的条件，返回相应的items；
 
 @return    NSArray
 */
- (NSArray* )dataForKey:(NSString* )key value:(id)value forName:(NSString* )name;

@end
