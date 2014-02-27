//
//  YDTaskManager.h
//  Yuedu
//
//  Created by xuwf on 13-10-28.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import <Foundation/Foundation.h>


enum {
    TaskStatusReady = 0,
    TaskStatusDownloading,
    TaskStatusPause,
    TaskStatusDone,
};
typedef NSInteger TaskStatus;

@interface YDTaskItem : NSObject <NSCoding> {
    ArticleItem*    _article;
    NSString*       _localPath;
    int64_t         _totalLength;
    int64_t         _recvLength;
    TaskStatus      _status;
}

@property (nonatomic, readonly) ArticleItem* article;
@property (nonatomic, readonly) TaskStatus status;
@property (nonatomic, readonly) NSString* localPath;
@property (nonatomic, assign) int64_t totalLength;
@property (nonatomic, assign) int64_t recvLength;
@property (nonatomic, readonly) float progress;

+ (id)itemWithArticle:(ArticleItem* )article;

@end

extern NSString* YDTaskManagerTaskDidUpdated;

@interface YDTaskManager : NSObject
SINGLETON_AS(YDTaskManager);

@property (nonatomic, readonly) NSArray* doneTasks;
@property (nonatomic, readonly) NSArray* undoneTasks;

- (void)load:(void(^)(void))completion;

/* 检测是否已经在本地 */
- (NSURL* )mp3URLForArticle:(ArticleItem* )item;

- (void)addTask:(YDTaskItem* )item;
- (void)addTasksFromArray:(NSArray* )items;
- (void)removeTask:(YDTaskItem* )item;
- (void)removeDoneTasks;
- (void)removeUndoneTasks;
- (void)removeAllTasks;
- (void)cache;

@end
