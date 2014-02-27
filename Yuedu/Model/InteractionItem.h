
/*!
 * Copyright (c) 2013,福建星网视易信息系统有限公司
 * All rights reserved.
 
 * @File:       InteractionItem.h
 * @Abstract:   交互单元，主要用于管理簇请求
 * @History:
 
 -2013-09-22 创建 by xuwf
 */

#import <Foundation/Foundation.h>

enum {
    ClusterRequestTypeChannel = 0,
    ClusterRequestTypeArticleList,
    ClusterRequestTypeArticleDetail,
    ClusterRequestTypeMax,
};

typedef NSInteger ClusterRequestType;

typedef void(^CompletionBlock)(BOOL success, id result);

@interface InteractionItem : NSObject {
    ClusterRequestType  _type;              /* 簇请求 */
    NSMutableArray*     _requests;          /* 簇下所有请求 */
    CompletionBlock     _completionBlock;   /* 结束块 */
}
@property (nonatomic, assign) ClusterRequestType type;
@property (nonatomic, copy) CompletionBlock completion; /* block需要使用copy，因为block一般定义为局部变量（栈上） */

- (id)initWithClusterType:(ClusterRequestType )type completion:(CompletionBlock)completion;
- (void)addRequest:(NetRequest* )request;
- (void)removeRequest:(NetRequest* )request;
- (BOOL)containsRequest:(NetRequest* )request;

/* 是否无子请求 */
- (BOOL)isEmpty;

@end
