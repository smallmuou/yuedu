//
//  YDHomeViewController.h
//  Yuedu
//
//  Created by xuwf on 13-10-16.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YDHomeViewController : UIViewController
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) IBOutlet LeoLoadingView* loadingView;

- (void)reloadWithOffset:(NSUInteger)offset count:(NSUInteger)count;
@end
