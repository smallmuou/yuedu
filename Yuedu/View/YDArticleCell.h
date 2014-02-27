//
//  YDArticleCell.h
//  Yuedu
//
//  Created by xuwf on 13-10-16.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YDArticleCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UIImageView* thumbView;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UILabel* authorLabel;
@property (nonatomic, strong) IBOutlet UILabel* playerLabel;
@property (nonatomic, strong) IBOutlet UIButton* addButton;
@property (nonatomic, strong) IBOutlet UILabel* favorLabel;
@property (nonatomic, strong) IBOutlet UILabel* listenLabel;
@property (nonatomic, strong) IBOutlet UILabel* durationLabel;

- (void)addTargetForAddButton:(id)target action:(SEL)action;
@end
