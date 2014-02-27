//
//  UIViewController+Navigation.m
//  Yuedu
//
//  Created by xuwf on 13-10-17.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "UIViewController+Navigation.h"

@implementation UIViewController (Navigation)
- (void)showMenuBarItem:(SEL)action {
    UIButton* menuButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 41, 30)];
    [menuButton setImage:IMG(@"bbmenu") forState:UIControlStateNormal];
    [menuButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    self.mm_drawerController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
}

- (void)showLogoView {
    self.mm_drawerController.navigationItem.titleView = [[UIImageView alloc] initWithImage:IMG(@"nav-logo")];
}

- (void)showPlayingBarItem:(SEL)action {
    UIButton* nowplayButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 41, 30)];
    [nowplayButton setImage:IMG(@"button-nowplay") forState:UIControlStateNormal];
    [nowplayButton setImage:IMG(@"button-nowplay-h") forState:UIControlStateHighlighted];
    [nowplayButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    self.mm_drawerController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:nowplayButton];
}

@end
