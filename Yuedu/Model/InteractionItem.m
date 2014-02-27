
/*!
 * Copyright (c) 2013,福建星网视易信息系统有限公司
 * All rights reserved.
 
 * @File:       InteractionItem.m
 * @Abstract:   交互单元，主要用于管理簇请求
 * @History:
 
 -2013-09-22 创建 by xuwf
 */


#import "InteractionItem.h"

@implementation InteractionItem
@synthesize type = _type;
@synthesize completion = _completion;

- (id)initWithClusterType:(ClusterRequestType )type completion:(CompletionBlock)completion {
    self = [super init];
    if (self) {
        _type = type;
        _completion = completion;
        _requests = [NSMutableArray array];
    }
    return self;
}

- (void)addRequest:(NetRequest* )request {
    if (request) {
        [_requests addObject:request];
    }
}

- (void)removeRequest:(NetRequest* )request {
    if (request) {
        [_requests removeObject:request];
    }
}

- (BOOL)containsRequest:(NetRequest* )request {
    return [_requests containsObject:request];
}

/* 是否无子请求 */
- (BOOL)isEmpty {
    return (0 == [_requests count]) ? YES : NO;
}

@end
