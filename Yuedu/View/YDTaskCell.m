//
//  YDTaskCell.m
//  Yuedu
//
//  Created by xuwf on 13-10-29.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "YDTaskCell.h"

@interface YDTaskItem () {
    UIView* _progressView;
}

@end

@implementation YDTaskCell
@synthesize progressView = _progressView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
