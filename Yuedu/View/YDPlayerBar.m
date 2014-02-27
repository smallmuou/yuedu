//
//  YDPlayerBar.m
//  Yuedu
//
//  Created by xuwf on 13-10-20.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "YDPlayerBar.h"

#define POINT_OFFSET    (2)

@interface YDPlayerBar () {
    UIProgressView* _progressView;
}

@end

@implementation YDPlayerBar

- (void)awakeFromNib {
    [self initProgressView];
}

- (void)initProgressView {
    CGRect rect = self.bounds;

    rect.origin.x += POINT_OFFSET;
    rect.size.width -= POINT_OFFSET*2;
    _progressView = [[UIProgressView alloc] initWithFrame:rect];
    
    CGPoint center = _progressView.center;
    center.y = self.bounds.size.height/2;
    _progressView.center = center;
    _progressView.userInteractionEnabled = NO;

    [self addSubview:_progressView];
    [self sendSubviewToBack:_progressView];
    _progressView.progress = 0.5;
//    _progressView.progressTintColor = [UIColor redColor];
//    _progressView.trackTintColor = [UIColor lightGrayColor];
//    self.maximumTrackTintColor = [UIColor clearColor];

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initProgressView];
    }
    return self;
}


/* Gettings & Settings */
- (UIColor* )middleTrackTintColor {
    return _progressView.progressTintColor;
}

- (void)setMiddleTrackTintColor:(UIColor *)middleTrackTintColor {
    _progressView.progressTintColor = middleTrackTintColor;
}


- (UIImage* )middleTrackImage {
    return _progressView.progressImage;
}

- (void)setMiddleTrackImage:(UIImage *)image {
    _progressView.progressImage = image;
}

- (UIColor* )maximumTrackTintColor {
    return _progressView.trackTintColor;
}
- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor {
    [super setMaximumTrackTintColor:maximumTrackTintColor];
}

#if 1

//- (UIImage *)maximumTrackImageForState:(UIControlState)state {
//    [super maximumTrackImageForState:state];
//    return _progressView.trackImage;
//}

- (void)setMaximumTrackImage1:(UIImage *)image {
    [super setMaximumTrackImage:[UIImage imageWithColor:[UIColor clearColor] size:image.size] forState:UIControlStateNormal];
    _progressView.trackImage = image;
}
#endif

@end
