//
//  YDPlayer.m
//  Yuedu
//
//  Created by xuwf on 13-10-21.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "YDPlayer.h"

NSString* MPMediaItemPropertyImageURL = @"MPMediaItemPropertyImageURL";
NSString* PlayModeKey = @"PlayModeKey";

@interface YDPlayer () <SDWebImageManagerDelegate> {
    AVPlayer*       _player;
    PlayMode        _playMode;
    PlayStatus      _playStatus;
    ArticleItem*    _currentItem;
    NSUInteger      _currentIndex;
    NSArray*        _playlist;
}

@end

@implementation YDPlayer
@synthesize currentItem;
@synthesize playStatus;
@synthesize playMode = _playMode;
@synthesize playlist = _playlist;

SINGLETON_DEF(YDPlayer);

- (id)init {
    self = [super init];
    if (self) {
        [self addObserver];
        
        _currentIndex = NSNotFound;
        _playMode = [USER_CONFIG(PlayModeKey) integerValue];
        srand((int)time(0));
        _playlist = [SINGLETON_CALL(InteractionManager) playlist];
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        [session setActive:YES error:nil];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver];
}

- (void)addObserver {
    [self registerNotify:PlaylistDataUpdatedNotifaction selector:@selector(playlistUpdated:)];
}

- (void)removeObserver {
    [self unregisterAllNotify];
    if (_player) {
        [_player removeObserver:self forKeyPath:@"rate" context:nil];
    }
}

- (ArticleItem* )currentItem {
    return _currentItem;
}

- (PlayStatus )playStatus {
    return _playStatus;
}

- (void)setPlayMode:(PlayMode)playMode {
    _playMode = playMode;
    USER_SET_CONFIG(PlayModeKey, INT_NUMBER(_playMode));
}

- (void)playlistUpdated:(NSNotification* )notification {
    _currentIndex = _playlist ? [_playlist indexOfObject:_currentItem] : _currentIndex;
    
    _playlist = [SINGLETON_CALL(InteractionManager) playlist];
    KVO_CHANGE(@"playlist");
    if (![_playlist count]) {
        [self stop];
    }

    if (NSNotFound == _currentIndex) {
        _currentItem = [_playlist objectAtIndex:0];
        [self start];
    } else {
        NSUInteger index = NSNotFound;
        for (ArticleItem* item in _playlist) {
            if (NSOrderedSame == [_currentItem compareWithObject:item]) {
                _currentItem = item;
                index = [_playlist indexOfObject:item];
                break;
            }
        }
        
        if (NSNotFound == index) {
            _currentIndex -= 1;
            [self nextWithAutomatic:YES];
        } else {
            _currentIndex = index;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"rate"]) {
        if (_player.rate == 0 && (self.current >= self.duration)) {
            _playStatus = PlayStatusStop;
            KVO_CHANGE(@"playStatus");
            [self nextWithAutomatic:YES];
        }
    }
}

- (NSTimeInterval)current {
    return CMTimeGetSeconds(_player.currentTime);
}

- (NSTimeInterval)duration {
    return CMTimeGetSeconds(_player.currentItem.duration);
}

- (NSTimeInterval)available {
    return [_player.currentItem availableDuration];
}

- (void)start {
    if (_currentItem) {
        NSURL* url = [SINGLETON_CALL(YDTaskManager) mp3URLForArticle:_currentItem];
        [self stop];
        
        _player = [AVPlayer playerWithURL:url];
        _currentIndex = [_playlist indexOfObject:_currentItem];
        KVO_CHANGE(@"currentItem");

        [_player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        
        UIBackgroundTaskIdentifier newTaskId = UIBackgroundTaskInvalid;
        UIBackgroundTaskIdentifier oldTaskId = UIBackgroundTaskInvalid;

        [_player play];
        if ([USER_CONFIG(SettingsAutoPlayKey) boolValue]) {
            YDTaskItem* task = [YDTaskItem itemWithArticle:_currentItem];
            [SINGLETON_CALL(YDTaskManager) addTask:task];
        }
        
        newTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
        if (newTaskId != UIBackgroundTaskInvalid && oldTaskId != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask: oldTaskId];
        }
        
        [self updatePlayingInfoCenter];        
        dispatch_async(dispatch_get_main_queue(), ^{
            _playStatus = PlayStatusPlay;
            KVO_CHANGE(@"playStatus");
        });
    }
}

- (void)stop {
    if (_player) {
//        _player.rate = 0;
        [_player removeObserver:self forKeyPath:@"rate" context:nil];
        _player = nil;
    }
}

- (void)restart {
    _currentItem = [_playlist count] ? [_playlist firstObject]:nil;
    [self start];
}

- (void)playWithIndex:(NSUInteger )index {
    if ([_playlist count] <= index) return;
    _currentItem = [_playlist objectAtIndex:index];
    [self start];
}

- (void)pause {
    _playStatus = PlayStatusPause;
    [_player pause];
    KVO_CHANGE(@"playStatus");
}

- (void)resume {
    if (_playStatus == PlayStatusPause) {
        [_player play];
        _playStatus = PlayStatusPlay;
        KVO_CHANGE(@"playStatus");
    } else {
        [self start];
    }
}

- (void)toggle {
    if (_playStatus == PlayStatusPlay) {
        [self pause];
    } else {
        [self resume];
    }
}

- (void)next {
    [self nextWithAutomatic:NO];
}

- (void)nextWithAutomatic:(BOOL)automatic {
    NSUInteger count = [_playlist count];
    if (!count) return;

    switch (_playMode) {
        case PlayModeOrder:
            _currentIndex++;
            _currentIndex = (_currentIndex >= count)?NSNotFound:_currentIndex;
            break;
        case PlayModeRepeatOne:
            if (automatic) {
                _currentIndex = [_playlist containsObject:_currentItem] ? _currentIndex : _currentIndex++;
                break;
            } else {
                _currentIndex++;
                _currentIndex = (_currentIndex >= count)?NSNotFound:_currentIndex;
            }
            break;
        case PlayModeShuffle:
            _currentIndex = rand()%count;
            break;
        default:
            break;
    }
    if (_currentIndex != NSNotFound) {
        _currentItem = [_playlist objectAtIndex:_currentIndex];
        [self start];
    }
    
}

- (void)previous {
    NSUInteger count = [_playlist count];
    if (!count) return;
    switch (_playMode) {
        case PlayModeOrder:
        case PlayModeRepeatOne:
            _currentIndex--;
            _currentIndex = (_currentIndex < count)? NSNotFound:_currentIndex;
            break;
        case PlayModeShuffle:
            _currentIndex = rand()%count;
            break;
        default:
            break;
    }
    
    if (_currentIndex != NSNotFound) {
        _currentItem = [_playlist objectAtIndex:_currentIndex];
        [self start];
    }
}

- (void)seek:(NSTimeInterval)time completion:(void (^)(BOOL finished))completion {
    CMTime seekTime = CMTimeMakeWithSeconds(time, 1);
    [_player seekToTime:seekTime completionHandler:completion];
}

- (void)updatePlayingInfoCenter {
    if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
        NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
        

        NSURL* url = [NSURL URLWithString:_currentItem.bgURL];

        [info setObject:_currentItem.title forKey:MPMediaItemPropertyTitle];
        [info setObject:_currentItem.player forKey:MPMediaItemPropertyArtist];
        [info setObject:_currentItem.bgURL forKey:MPMediaItemPropertyImageURL];
        
        UIImage* image = [[SDWebImageManager sharedManager] imageWithURL:url];
        if (image) {
            MPMediaItemArtwork * mArt = [[MPMediaItemArtwork alloc] initWithImage:image];
            [info setObject:mArt forKey:MPMediaItemPropertyArtwork];
        } else {
            [[SDWebImageManager sharedManager] downloadWithURL:url delegate:self];
        }
    
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:info];
    }

}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image forURL:(NSURL *)url {
    NSDictionary* info = [[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo];
    if ([[info objectForKey:MPMediaItemPropertyImageURL] isEqualToString:url.absoluteString]) {
        NSMutableDictionary* aInfo = [NSMutableDictionary dictionaryWithDictionary:info];
        MPMediaItemArtwork * mArt = [[MPMediaItemArtwork alloc] initWithImage:image];
        [aInfo setObject:mArt forKey:MPMediaItemPropertyArtwork];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:aInfo];
    }
}


@end
