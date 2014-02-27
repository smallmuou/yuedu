//
//  YDArticleCell.m
//  Yuedu
//
//  Created by xuwf on 13-10-16.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "YDArticleCell.h"
#import <objc/message.h>

@interface YDArticleCell () {
    UIImageView*    _thumbView;
    UILabel*        _titleLabel;
    UILabel*        _authorLabel;
    UILabel*        _playerLabel;
    UIButton*       _addButton;
    UILabel*        _favorLabel;
    UILabel*        _listenLabel;
    UILabel*        _durationLabel;
    
    id              _target __weak;
    SEL             _action;
}

@end

@implementation YDArticleCell
@synthesize thumbView = _thumbView;
@synthesize titleLabel = _titleLabel;
@synthesize authorLabel = _authorLabel;
@synthesize playerLabel = _playerLabel;
@synthesize addButton = _addButton;
@synthesize favorLabel = _favorLabel;
@synthesize durationLabel = _durationLabel;

- (void)awakeFromNib {
    self.thumbView.layer.masksToBounds = YES;
    self.thumbView.layer.cornerRadius = 3;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

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

- (void)addTargetForAddButton:(id)target action:(SEL)action {
    _target = target;
    _action = action;
    [self.addButton addTarget:self action:@selector(onAddButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onAddButtonPressed:(id)sender {
    if (_target && _action) {
        objc_msgSend(_target, _action, self);
    }
}

@end
