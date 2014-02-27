//
//  YDSubMenuCell.m
//  Yuedu
//
//  Created by xuwf on 13-10-16.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "YDSubMenuCell.h"

@interface YDSubMenuCell () {
    UIImageView* _iconView;
    UILabel* _titleLabel;
}

@end

@implementation YDSubMenuCell
@synthesize iconView = _iconView;
@synthesize titleLabel = _titleLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
