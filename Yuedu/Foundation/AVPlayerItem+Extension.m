//
//  AVPlayerItem+Extension.m
//  Yuedu
//
//  Created by xuwf on 13-10-19.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "AVPlayerItem+Extension.h"

@implementation AVPlayerItem (Extension)
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [self loadedTimeRanges];
    if ([loadedTimeRanges count]) {
        CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval result = startSeconds + durationSeconds;
        return result;
    }
    return 0;
}
@end
