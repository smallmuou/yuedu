
/*!
 * Copyright (c) 2013,福建星网视易信息系统有限公司
 * All rights reserved.
 
 * @File:       InteractionManager.h
 * @Abstract:   交互管理
 * @History:
 
 -2013-09-03 创建 by xuwf
 */

#import "InteractionManager.h"
#import "NSObject+Extension.h"

NSString* const ChannelDataUpdatedNotification = @"ChannelDataUpdatedNotification";
NSString* const ArticleListDataUpdatedNotification = @"ArticleListDataUpdatedNotification";
NSString* const PlaylistDataUpdatedNotifaction = @"PlaylistDataUpdatedNotifaction";
NSString* const FavorlistDataUpdatedNotifaction = @"FavorlistDataUpdatedNotifaction";

@interface InteractionManager () {
    DataCenter*     _dataCenter;
    NSMutableArray* _clusterRequests; /* InteractionItems */
    TMCache*        _cache;
}

@end

@implementation InteractionManager
SINGLETON_DEF(InteractionManager);

- (id)init {
    self = [super init];
    if (self) {
        _dataCenter = [[DataCenter alloc] init];
        _clusterRequests = [NSMutableArray array];
        _cache = [[TMCache alloc] initWithName:@"Cache"];
        [_dataCenter registerForKeysFromArray:[NSArray arrayWithObjects:
                                               ChannelDataUpdatedNotification,
                                               ArticleListDataUpdatedNotification,
                                               PlaylistDataUpdatedNotifaction,
                                               FavorlistDataUpdatedNotifaction,
                                               nil]];
        
        [self registerNotify:NetManagerInteractionDidSuccessNotification selector:@selector(netManagerInteractionDidSuccessNotification:)];
        [self registerNotify:NetManagerInteractionFailNotification selector:@selector(netManagerInteractionFailNotification:)];
        [self registerNotify:NetManagerInteractionAuthFailNotfication selector:@selector(netManagerInteractionAuthFailNotfication:)];
        
        /* Load Playlist From Local File */
        [_cache objectForKey:PlaylistDataUpdatedNotifaction.MD5 block:^(TMCache *cache, NSString *key, id object) {
            [_dataCenter addItemsFromArray:object forKey:PlaylistDataUpdatedNotifaction clear:YES];
        }];
    }
    return self;
}

- (void)cache {
    [_cache setObject:[_dataCenter dataForKey:PlaylistDataUpdatedNotifaction] forKey:PlaylistDataUpdatedNotifaction.MD5 block:NULL];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ClusterRequests
- (InteractionItem* )itemForRequest:(NetRequest* )request{
    if (!request) return nil;
    @synchronized(_clusterRequests) {
        for (InteractionItem* item in _clusterRequests) {
            if ([item containsRequest:request]) return item;
        }
        return nil;
    }
}

- (BOOL)containsRequestType:(ClusterRequestType )type {
    @synchronized(_clusterRequests) {
        for (InteractionItem* item in _clusterRequests) {
            if (item.type == type) return YES;
        }
        return NO;
    }
}

- (InteractionItem* )addItemWithType:(ClusterRequestType)type completion:(CompletionBlock)completion request:(NetRequest* )request {
    @synchronized(_clusterRequests) {
        InteractionItem* item = [[InteractionItem alloc] initWithClusterType:type completion:completion];
        [item addRequest:request];
        [_clusterRequests addObject:item];
        return item;
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Interaction
- (void)requestForChannel:(CompletionBlock)completion {
    id req = [SINGLETON_CALL(NetManager) interaction:HTTPRequestTypeChannel userInfo:nil];
    [self addItemWithType:ClusterRequestTypeChannel completion:completion request:req];
}

- (NSArray* )channels {
    return [_dataCenter dataForKey:ChannelDataUpdatedNotification];
}

- (void)requestForArticleList:(CompletionBlock)completion {
    id req = [SINGLETON_CALL(NetManager) interaction:HTTPRequestTypeArticleList userInfo:nil];
    [self addItemWithType:ClusterRequestTypeArticleList completion:completion request:req];
}

- (NSArray* )articles {
    return [_dataCenter dataForKey:ArticleListDataUpdatedNotification];
}

- (void)requestDetailForArticle:(ArticleItem* )item completion:(CompletionBlock)completion {
    [_cache objectForKey:[self contentKeyForSid:[NSString stringWithFormat:@"%d", item.sid]] block:^(TMCache *cache, NSString *key, id object) {
        if (object) {
            if (completion) completion(YES, object);
        } else {
            id req = [SINGLETON_CALL(NetManager) interaction:HTTPRequestTypeArticleDetail userInfo:INFO_DICTIONARY(item)];
            
            [self addItemWithType:ClusterRequestTypeArticleDetail completion:completion request:req];
        }
    }];
}

- (NSArray* )playlist {
    return [_dataCenter dataForKey:PlaylistDataUpdatedNotifaction];
}

- (void)addItemToPlaylist:(ArticleItem* )item first:(BOOL)first {
    item.existOnPlaylist = YES;
    if (first) {
        [_dataCenter insertItem:item forKey:PlaylistDataUpdatedNotifaction];
    } else {
        [_dataCenter updateItem:item forKey:PlaylistDataUpdatedNotifaction update:YES];
    }
    [_dataCenter updateItem:item forKey:ArticleListDataUpdatedNotification update:NO];
}

- (void)removeItemFromPlaylist:(ArticleItem* )item {
    item.existOnPlaylist = NO;
    [_dataCenter removeItem:item forKey:PlaylistDataUpdatedNotifaction];
    [_dataCenter updateItem:item forKey:ArticleListDataUpdatedNotification update:NO];
}

- (void)removeAllItemsFromPlaylist {
    NSArray* playlist = [_dataCenter dataForKey:PlaylistDataUpdatedNotifaction];
    if (![playlist count]) return;
    
    for (ArticleItem* item in playlist) {
        item.existOnPlaylist = NO;
    }
    [_dataCenter updateItemsFromArray:playlist forKey:ArticleListDataUpdatedNotification];
    [_dataCenter removeAllItemsForKey:PlaylistDataUpdatedNotifaction];

}

- (NSArray* )favors {
    return [_dataCenter dataForKey:FavorlistDataUpdatedNotifaction];
}

- (void)addItemToFavor:(ArticleItem* )item {
    item.favor = YES;
    [_dataCenter updateItem:item forKey:FavorlistDataUpdatedNotifaction update:YES];
    [_dataCenter updateItem:item forKey:ArticleListDataUpdatedNotification update:NO];
}

- (void)removeItemFromFavor:(ArticleItem* )item {
    item.favor = NO;
    [_dataCenter removeItem:item forKey:FavorlistDataUpdatedNotifaction];
    [_dataCenter updateItem:item forKey:ArticleListDataUpdatedNotification update:NO];
}


////////////////////////////////////////////////////////////////////////////////
- (void)clearAllData {
    [_dataCenter removeAllItems];
}

#pragma mark - NetManager notifications
- (void)check:(NetRequest* )request success:(BOOL)success result:(id)result {
    @synchronized(_clusterRequests) {
        InteractionItem* iItem = [self itemForRequest:request];
        if (iItem) {
            [iItem removeRequest:request];
            if ([iItem isEmpty]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (iItem.completion) iItem.completion(success, result);
                });
                [_clusterRequests removeObject:iItem];
            }
        }
    }
}

- (NSString* )contentKeyForSid:(NSString* )sid {
    return [[NSString stringWithFormat:@"%@_content", sid] MD5];
}

- (void)netManagerInteractionDidSuccessNotification:(NSNotification* )notification {
    NetRequest* request = [notification object];
    InteractionItem* iItem = [self itemForRequest:request];

    id result;
    switch (request.type) {
        case HTTPRequestTypeChannel:
            result = RESULT_ITEM(notification.userInfo);
            [_dataCenter addItemsFromArray:result forKey:ChannelDataUpdatedNotification clear:YES];
            [_cache setObject:result forKey:[ChannelDataUpdatedNotification MD5]];
            break;
        case HTTPRequestTypeArticleList: {
            result = RESULT_ITEM(notification.userInfo);
                        
            /* 更新播放列表的aid */
            NSArray* playlist = [_dataCenter dataForKey:PlaylistDataUpdatedNotifaction];
            for (ArticleItem* item in playlist) {
                for (ArticleItem* article in result) {
                    if (NSOrderedSame == [item compareWithObject:article]) {
                        item.aid = article.aid;
                        article.existOnPlaylist = YES;
                        break;
                    }
                }
            }
            
            [_dataCenter addItemsFromArray:result forKey:ArticleListDataUpdatedNotification clear:YES];
            id req = [SINGLETON_CALL(NetManager) interaction:HTTPRequestTypeAlbum userInfo:nil];
            [iItem addRequest:req];
            break;
        }
        case HTTPRequestTypeAlbum: {
            NSArray* albums = RESULT_ITEM(notification.userInfo);
            NSArray* articles = [_dataCenter dataForKey:ArticleListDataUpdatedNotification];
            int articleCount = [articles count];
            int i = 0;
            for (YDAlbumItem* album in albums) {
                ArticleItem* article = (articleCount > i)?[articles objectAtIndex:i]:nil;
                if (!article || article.sid != album.sid) {
                    break;
                }
                article.album = album;
                i++;
            }
            result = articles;
            [_dataCenter addItemsFromArray:result forKey:ArticleListDataUpdatedNotification clear:YES];
            [_cache setObject:result forKey:[ArticleListDataUpdatedNotification MD5]];
            break;
        }
        case HTTPRequestTypeArticleDetail:
            result = RESULT_ITEM(notification.userInfo);            
            [_cache setObject:result forKey:[self contentKeyForSid:RESULT_REVERSE(notification.userInfo)]];;
            break;
        default:
            break;
    }
    [self check:request success:YES result:result];
}

- (void)netManagerInteractionAuthFailNotfication:(NSNotification* )notification {
    NetRequest* request = [notification object];
    [self check:request success:NO result:nil];
}

- (void)netManagerInteractionFailNotification:(NSNotification* )notification {
    NetRequest* request = [notification object];

    [self check:request success:NO result:nil];
}

@end
