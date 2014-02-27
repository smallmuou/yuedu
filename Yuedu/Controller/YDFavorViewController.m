//
//  YDFavorViewController.m
//  Yuedu
//
//  Created by xuwf on 13-10-21.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "YDFavorViewController.h"
#import "YDPlayingViewController.h"

@interface YDFavorViewController () <UITableViewDataSource, UITableViewDelegate> {
    UITableView*        _tableView;
    NSMutableArray*     _tableData;
    
}

@end

@implementation YDFavorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = LOCALIZE(@"favor");
        [self addObserver];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self showMenuBarItem:@selector(onMenuButtonPressed:)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableData = [NSMutableArray arrayWithArray:[SINGLETON_CALL(InteractionManager) favors]];
}

- (void)dealloc {
    [self removeObserver];
}

- (void)addObserver {
}

- (void)removeObserver {
    [self unregisterAllNotify];
}

- (void)viewWillAppear:(BOOL)animated {
    [self favorUpdated];
}

- (void)favorUpdated {
    _tableData = [NSMutableArray arrayWithArray:[SINGLETON_CALL(InteractionManager) favors]];
    [_tableView reloadData];
}

- (void)onMenuButtonPressed:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:NULL];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"ArticleCell";
    YDArticleCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [CustomViews customViewsWithTag:CustomViewArticleCell];
        cell.thumbView.layer.masksToBounds = YES;
        cell.thumbView.layer.cornerRadius = 3;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    ArticleItem* item = [_tableData objectAtIndex:indexPath.row];
    
    [cell.thumbView setImageWithURL:[NSURL URLWithString:[item.thumbURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                   placeholderImage:IMG(@"thumb-default")];
    
    cell.titleLabel.text = item.title;
    cell.titleLabel.numberOfLines = 2;
    cell.authorLabel.text = [NSString stringWithFormat:@"%@: %@", LOCALIZE(@"author"), item.author];
    cell.playerLabel.text = [NSString stringWithFormat:@"%@: %@", LOCALIZE(@"player"), item.player];
    cell.listenLabel.text = item.listen;
    cell.durationLabel.text = item.duration;
    [cell.addButton setImage:IMG(@"button-playlistremove") forState:UIControlStateNormal];
    [cell addTargetForAddButton:self action:@selector(onAddButtonPressed:)];
    
    return cell;
}

- (void)onAddButtonPressed:(UITableViewCell* )cell {
    NSIndexPath* indexPath = [_tableView indexPathForCell:cell];
    
    ArticleItem* item = ([_tableData count] > indexPath.row)?[_tableData objectAtIndex:indexPath.row]:nil;
    [SINGLETON_CALL(InteractionManager) removeItemFromFavor:item];
    
    [_tableData removeObject:item];
    [_tableView beginUpdates];
    [_tableView deleteRowsAtIndexPaths:ARRAY(indexPath) withRowAnimation:UITableViewRowAnimationFade];
    [_tableView endUpdates];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YDPlayingViewController* pvc = [[YDPlayingViewController alloc] initWithNibName:@"YDPlayingViewController" bundle:nil];
    [self.navigationController pushViewController:pvc animated:YES];
}


@end
