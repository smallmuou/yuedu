//
//  YDSectionHeaderView.m
//  Yuedu
//
//  Created by xuwf on 13-10-29.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "YDSectionHeaderView.h"

@interface YDSectionHeaderView () {
    UIImageView*    _backgroundView;
    UILabel*        _titleLabel;
    UIButton*       _addButton;
}

@end

@implementation YDSectionHeaderView
@synthesize backgroundView = _backgroundView;
@synthesize titleLabel = _titleLabel;
@synthesize addButton = _addButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
