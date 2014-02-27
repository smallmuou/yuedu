
/*!
 * Copyright (c) 2013,福建星网视易信息系统有限公司
 * All rights reserved.
 
 * @File:       DataCenter.m
 * @Abstract:   数据中心
 * @History:
 
 -2013-09-03 创建 by xuwf
 */


#import "DataCenter.h"

#define UPDATE_MIN_TIMESTAMPS  (0.2)  /* 最新更新间隔 */

@interface UpdatedItem : NSObject {
    SEL sel;
}

@end

@interface DataCenter () {
    NSMutableDictionary*    _center;
    NSMutableDictionary*    _timestamps;
    BOOL                    _copyAble;
    
}
@end

@implementation DataCenter

- (id)init {
    self = [super init];
    if (self) {
        _center = [NSMutableDictionary dictionary];
        _timestamps = [NSMutableDictionary dictionary];
        _copyAble = NO;/* 不进行拷贝 */
    }
    return self;
}

- (void)registerForKey:(NSString* )key {
    NSMutableArray* array = [NSMutableArray array];
    [_center setValue:array forKey:key];
}

- (void)registerForKeysFromArray:(NSArray* )keys {
    for (NSString* key in keys) {
        [self registerForKey:key];
    }
}

- (void)unregisterForKey:(NSString* )key {
    [_center removeObjectForKey:key];
}

- (void)unregisterAllKeys {
    [_center removeAllObjects];
}


- (NSUInteger )indexOfItem:(id)aItem inTable:(NSMutableArray* )table {
    NSUInteger index = NSIntegerMax;
    
    index = [table indexOfObject:aItem];
    if (index != NSIntegerMax) return index;
    
    for (id item in table) {
        if (NSOrderedSame == [item compareWithObject:aItem]) {
            index = [table indexOfObject:item];
            break;
        }
    }
    return index;
}

- (void)updatedNotificationForKey:(NSString* )key {
    POST_NOTIFY(key, [self dataForKey:key], nil);
}

/* 
 更新机制:保证50ms内不重复更新，防止UI更新过快
 */
- (void)postUpdateNotificationForKey:(NSString* )key{
    if (!key) return;
    @synchronized(_timestamps) {
        NSTimeInterval nowTimestamp = [NSDate timeIntervalSinceReferenceDate];
        
        NSTimeInterval lastTimestamp = DOUBLE_VALUE([_timestamps objectForKey:key]);
        NSTimeInterval diffTimestamp = nowTimestamp - lastTimestamp;
        if (diffTimestamp > UPDATE_MIN_TIMESTAMPS) {
            [self updatedNotificationForKey:key];
            [_timestamps setValue:DOUBLE_NUMBER(nowTimestamp) forKey:key];
        } else if (diffTimestamp > 0) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updatedNotificationForKey:) object:key];
            [self performSelector:@selector(updatedNotificationForKey:) withObject:key afterDelay:UPDATE_MIN_TIMESTAMPS];
            
            nowTimestamp += UPDATE_MIN_TIMESTAMPS;
            [_timestamps setValue:DOUBLE_NUMBER(nowTimestamp) forKey:key];
        }
    }
}

- (void)addItem:(id)item forKey:(NSString* )key  clear:(BOOL)clear{
    if (!item) return;
    
    @synchronized(_center) {
        NSMutableArray* aArray = [_center objectForKey:key];
        if (clear) [aArray removeAllObjects];
        
        if (aArray) {
            [aArray addObject:item];
            POST_NOTIFY(key, aArray, nil);
        }
    }
}

- (void)addItemsFromArray:(NSArray* )array forKey:(NSString* )key  clear:(BOOL)clear{
    if (![array count]) return;
    
    @synchronized(_center) {
        NSMutableArray* aArray = [_center objectForKey:key];
        if (clear) [aArray removeAllObjects];
        if (aArray) {
            [aArray addObjectsFromArray:array];
            [self postUpdateNotificationForKey:key];
        }
    }
}

- (void)insertItem:(id)item forKey:(NSString* )key {
    if (!item) return;
    
    @synchronized(_center) {
        NSMutableArray* aArray = [_center objectForKey:key];
        NSUInteger index = [self indexOfItem:item inTable:aArray];
        if (index != NSNotFound) {
            [aArray removeObjectAtIndex:index];
        }
        
        if (aArray) {
            [aArray insertObject:item atIndex:0];
            POST_NOTIFY(key, aArray, nil);
        }
    }

}

- (void)updateItem:(id)item forKey:(NSString* )key update:(BOOL)update {
    @synchronized(_center) {
        NSMutableArray* aArray = [_center objectForKey:key];
        NSUInteger index = [self indexOfItem:item inTable:aArray];
        if (index != NSNotFound) {
            [aArray replaceObjectAtIndex:index withObject:item];
        } else {
            [aArray addObject:item];
        }
        if (update) [self postUpdateNotificationForKey:key];
    }
}

- (void)updateItemsFromArray:(NSArray* )array forKey:(NSString* )key {
    @synchronized(_center) {
        NSMutableArray* aArray = [_center objectForKey:key];
        for (id item in array) {
            NSUInteger index = [self indexOfItem:item inTable:aArray];
            if (index != NSNotFound) {
                [aArray replaceObjectAtIndex:index withObject:item];
            } else {
                [aArray addObject:item];
            }
        }
        [self postUpdateNotificationForKey:key];
    }
}

- (void)removeItem:(id)item forKey:(NSString* )key {
    @synchronized(_center) {
        NSMutableArray* aArray = [_center objectForKey:key];
        NSUInteger index = [self indexOfItem:item inTable:aArray];
        if (index != NSNotFound) {
            [aArray removeObjectAtIndex:index];
            [self postUpdateNotificationForKey:key];
        }
    }
}

- (void)removeItemsFromArray:(NSArray* )array forKey:(NSString* )key {
    @synchronized(_center) {
        NSMutableArray* aArray = [_center objectForKey:key];
        for (id item in array) {
            NSUInteger index = [self indexOfItem:item inTable:aArray];
            if (index != NSNotFound) {
                [aArray removeObjectAtIndex:index];
            }
        }
        [self postUpdateNotificationForKey:key];
    }
}

- (void)removeAllItemsForKey:(NSString* )key {
    @synchronized(_center) {
        NSMutableArray* aArray = [_center objectForKey:key];
        [aArray removeAllObjects];
        [self postUpdateNotificationForKey:key];
    }
}

- (void) removeAllItems {
    for (NSString* key in _center.allKeys) {
        [[_center objectForKey:key] removeAllObjects];
    }
}
/*!
 dataForType
 @param key   数据Key
 @param flag    是否copy
 @return 返回对应的数据
 */

- (NSArray* )dataForKey:(NSString* )key {
    return [[NSArray alloc] initWithArray:[_center objectForKey:key] copyItems:_copyAble];
}

/*!
 itemsForType:value:forKey
 @param     key   数据Key
 @param     value   条件值
 @param     name     键（见对应的item定义）
 
 根据给定的条件，返回相应的items；
 
 @return    NSArray
 */
- (NSArray* )dataForKey:(NSString* )key value:(id)value forName:(NSString* )name {

    NSArray* array = [_center objectForKey:key];
    NSMutableArray* result = [[NSMutableArray alloc] init];
    
    for (id item in array) {
        if (NSOrderedSame == [item compareValue:value forKey:name]) {
            [result addObject:item];
        }
    }
    return [[NSArray alloc] initWithArray:result copyItems:_copyAble];
}


@end
