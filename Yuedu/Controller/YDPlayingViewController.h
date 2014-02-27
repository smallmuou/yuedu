//
//  YDPlayingViewController.h
//  Yuedu
//
//  Created by xuwf on 13-10-17.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YDPlayingViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIScrollView* scrollView;
@property (nonatomic, strong) IBOutlet UIView* containerView;
@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet UILabel* titleLablel;
@property (nonatomic, strong) IBOutlet UILabel* authorLabel;
@property (nonatomic, strong) IBOutlet UIButton* favorButton;
@property (nonatomic, strong) IBOutlet UIButton* shareButton;

/* Player */
@property (nonatomic, strong) IBOutlet YDSlider* slider;
@property (nonatomic, strong) IBOutlet UILabel* currentLabel;
@property (nonatomic, strong) IBOutlet UILabel* durationLabel;
@property (nonatomic, strong) IBOutlet UIButton* prevButton;
@property (nonatomic, strong) IBOutlet UIButton* nextButton;
@property (nonatomic, strong) IBOutlet UIButton* playButton;
@property (nonatomic, strong) IBOutlet UIButton* pauseButton;
@property (nonatomic, strong) IBOutlet UIButton* downloadButton;
@property (nonatomic, strong) IBOutlet UIButton* modeButton;
@property (nonatomic, strong) IBOutlet UIView* lineView;

@end
