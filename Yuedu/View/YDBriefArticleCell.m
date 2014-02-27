//
//  YDBriefArticleCell.m
//  Yuedu
//
//  Created by xuwf on 13-10-26.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "YDBriefArticleCell.h"

@interface YDBriefArticleCell () {
    UIImageView*    _thumbView;
    UILabel*        _titleLabel;
    UILabel*        _durationLabel;
}
@end

@implementation YDBriefArticleCell
@synthesize thumbView = _thumbView;
@synthesize titleLabel = _titleLabel;
@synthesize durationLabel = _durationLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
