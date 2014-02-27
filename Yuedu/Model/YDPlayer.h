//
//  YDPlayer.h
//  Yuedu
//
//  Created by xuwf on 13-10-21.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    PlayModeOrder = 0,
    PlayModeShuffle,
    PlayModeRepeatOne,
    PlayModeMax,
};
typedef NSInteger PlayMode;

enum {
    PlayStatusUnknown = 0,
    PlayStatusPlay,
    PlayStatusPause,
    PlayStatusStop,
};
typedef NSInteger PlayStatus;

@interface YDPlayer : NSObject

SINGLETON_AS(YDPlayer);

@property (nonatomic, readonly) ArticleItem* currentItem;
@property (nonatomic, assign) PlayMode playMode;
@property (nonatomic, readonly) PlayStatus playStatus;
@property (nonatomic, readonly) NSArray* playlist;

- (NSTimeInterval)current;
- (NSTimeInterval)duration;
- (NSTimeInterval)available;

- (void)playWithIndex:(NSUInteger )index;
- (void)restart;
- (void)pause;
- (void)resume;
- (void)next;
- (void)previous;
- (void)toggle;

- (void)seek:(NSTimeInterval)time completion:(void (^)(BOOL finished))completion;

@end
