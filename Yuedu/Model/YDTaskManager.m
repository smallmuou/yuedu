//
//  YDTaskManager.m
//  Yuedu
//
//  Created by xuwf on 13-10-28.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "YDTaskManager.h"

#define TASK_CACHE_NAME     (@"TaskCache")

@implementation YDTaskItem
@synthesize article = _article;
@synthesize localPath = _localPath;
@synthesize totalLength = _totalLength;
@synthesize recvLength = _recvLength;
@synthesize status = _status;

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_article forKey:@"article"];
    [aCoder encodeObject:_localPath forKey:@"localPath"];
    [aCoder encodeInt64:_totalLength forKey:@"totalLength"];
    [aCoder encodeInt64:_recvLength forKey:@"recvLength"];
    [aCoder encodeInteger:_status forKey:@"status"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _article = [aDecoder decodeObjectForKey:@"article"];
        _localPath = [aDecoder decodeObjectForKey:@"localPath"];
        _totalLength = [aDecoder decodeInt64ForKey:@"totalLength"];
        _recvLength = [aDecoder decodeInt64ForKey:@"recvLength"];
        _status = [aDecoder decodeIntegerForKey:@"status"];
    }
    return self;
}

- (float)progress {
    return (_totalLength > 0) ? (float)_recvLength/_totalLength : 0.0;
}

- (id)initWithArticle:(ArticleItem* )article {
    self = [super init];
    if (self) {
        _article = article;
        _status = TaskStatusReady;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _localPath = [NSString stringWithFormat:@"%@/%@/%@.mp3", [paths firstObject], TASK_CACHE_NAME, article.mp3URL.MD5];
    }
    return self;
}

+ (id)itemWithArticle:(ArticleItem* )article {
    return [[YDTaskItem alloc] initWithArticle:article];
}

@end

#pragma mark - YDTaskManager
static NSString* DoneTaskCacheKey = @"DoneTaskCacheKey";
static NSString* UndoneTaskCacheKey = @"UndoneTaskCacheKey";
NSString* YDTaskManagerTaskDidUpdated = @"YDTaskManagerTaskDidUpdated";

@interface YDTaskManager () <NetRequestDelegate> {
    NSMutableArray*     _doneTasks;     /* All tasks */
    NSMutableArray*     _undoneTasks;
    NSOperationQueue*   _queue;
    TMCache*            _cache;
}

@end

@implementation YDTaskManager
SINGLETON_DEF(YDTaskManager);

- (id)init {
    self = [super init];
    if (self) {
        _queue = [[NSOperationQueue alloc] init];
        [_queue setMaxConcurrentOperationCount:1];
        
        /* Create Cache Directory */
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString* path = [NSString stringWithFormat:@"%@/%@", [paths firstObject], TASK_CACHE_NAME];
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:NULL];
        
        _cache = [[TMCache alloc] initWithName:TASK_CACHE_NAME];
    }
    return self;
}

- (void)load:(void(^)(void))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        _doneTasks = [_cache objectForKey:DoneTaskCacheKey.MD5];
        _doneTasks = _doneTasks ? _doneTasks : [NSMutableArray array];
        KVO_CHANGE(@"doneTasks");

        _undoneTasks = [_cache objectForKey:UndoneTaskCacheKey.MD5];
        _undoneTasks = _undoneTasks ? _undoneTasks : [NSMutableArray array];
        KVO_CHANGE(@"undoneTasks");
        
        //add to queue
        for (YDTaskItem* task in _undoneTasks) {
            [self addTaskToQueue:task];
        }
        
        if (completion) completion();
    });
}

/* 检测是否已经在本地 */
- (NSURL* )mp3URLForArticle:(ArticleItem* )item {
    for (YDTaskItem* task in _doneTasks) {
        if (NSOrderedSame == [task.article compareWithObject:item]) {
            return [NSURL fileURLWithPath:task.localPath];
        }
    }
    return [NSURL URLWithString:item.mp3URL];
}

- (void)cache {
    [_cache setObject:_doneTasks forKey:DoneTaskCacheKey.MD5 block:NULL];
    [_cache setObject:_undoneTasks forKey:UndoneTaskCacheKey.MD5 block:NULL];
}

- (BOOL)checkExist:(YDTaskItem* )item {
    ArticleItem* article = item.article;
    if (!article) return NO;
    
    for (YDTaskItem* task in _doneTasks) {
        if (NSOrderedSame == [article compareWithObject:task.article]) {
            return YES;
        }
    }
    
    for (YDTaskItem* task in _undoneTasks) {
        if (NSOrderedSame == [article compareWithObject:task.article]) {
            return YES;
        }        
    }
    
    return NO;
}

- (void)addTaskToQueue:(YDTaskItem* )item {
    TaskRequest* request = [[TaskRequest alloc] initWithType:TASKRequestTypeArticleContent withAddress:nil port:0 userInfo:INFO_DICTIONARY(item)];
    request.delegate = self;
        
    [_queue addOperation:request];    
}

- (void)addTask:(YDTaskItem* )item {
    if (!item || !item.article) return;
    if ([self checkExist:item]) return;
    
    [_undoneTasks addObject:item];
    KVO_CHANGE(@"undoneTasks");
    [self addTaskToQueue:item];
}

- (void)addTasksFromArray:(NSArray* )items {
    
}

- (void)removeTask:(YDTaskItem* )item {
    if ([_undoneTasks containsObject:item]) {
#warning cacel
        [_undoneTasks removeObject:item];
    } else if ([_doneTasks containsObject:item]) {
        [_doneTasks removeObject:item];
        [[NSFileManager defaultManager] removeItemAtPath:item.localPath error:NULL];
    }
}

- (void)removeAllTasks {
    NSLog(@"removeAllTasks");
}

- (void)removeDoneTasks {
    NSLog(@"removeDoneTasks");

}

- (void)removeUndoneTasks {
    NSLog(@"removeUndoneTasks");

}


- (void)onNetRequest:(NetRequest*)request didSucceedWithResult:(NSDictionary*)result {
    YDTaskItem* task = RESULT_ITEM(result);
    [_undoneTasks removeObject:task];
    [_doneTasks insertObject:task atIndex:0];
    KVO_CHANGE(@"doneTasks");
    KVO_CHANGE(@"undoneTasks");
}

- (void)onNetRequest:(NetRequest*)request didFailWithError:(NSDictionary*)error {
    YDTaskItem* task = RESULT_ITEM(error);
    [_undoneTasks removeObject:task];
    KVO_CHANGE(@"undoneTasks");
}

- (void)onNetRequest:(NetRequest*)request didUpdatedWithInfo:(NSDictionary*)info {
    YDTaskItem* task = RESULT_ITEM(info);
    POST_NOTIFY(YDTaskManagerTaskDidUpdated, task, nil);
}

@end
