
/*!
 * Copyright (c) 2013,福建星网视易信息系统有限公司
 * All rights reserved.
 
 * @File:       InteractionManager.h
 * @Abstract:   交互管理
 * @History:
 
 -2013-09-03 创建 by xuwf
 */

#import <Foundation/Foundation.h>
#import "InteractionItem.h"

extern NSString* const ChannelDataUpdatedNotification;
extern NSString* const ArticleListDataUpdatedNotification;
extern NSString* const PlaylistDataUpdatedNotifaction;
extern NSString* const FavorlistDataUpdatedNotifaction;

@interface InteractionManager : NSObject
SINGLETON_AS(InteractionManager);

- (void)requestForChannel:(CompletionBlock)completion;
- (NSArray* )channels;

- (void)requestForArticleList:(CompletionBlock)completion;
- (NSArray* )articles;

- (void)requestDetailForArticle:(ArticleItem* )item completion:(CompletionBlock)completion;

- (NSArray* )playlist;
- (void)addItemToPlaylist:(ArticleItem* )item first:(BOOL)first;
- (void)removeItemFromPlaylist:(ArticleItem* )item;
- (void)removeAllItemsFromPlaylist;

- (NSArray* )favors;
- (void)addItemToFavor:(ArticleItem* )item;
- (void)removeItemFromFavor:(ArticleItem* )item;

- (void)cache;

@end
