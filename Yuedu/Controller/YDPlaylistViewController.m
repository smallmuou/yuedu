//
//  YDPlaylistViewController.m
//  Yuedu
//
//  Created by xuwf on 13-10-21.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "YDPlaylistViewController.h"
#import "YDPlayingViewController.h"

@interface YDPlaylistViewController () <UITableViewDataSource, UITableViewDelegate, RMEIdeasPullDownControlProtocol, RMEIdeasPullDownControlDataSource> {
    UITableView*        _tableView;
    NSMutableArray*     _tableData;

    RMEIdeasPullDownControl*    _pulldown;
    NSArray*                    _pulldownTitles;
    NSArray*                    _pulldownImages;
    NSArray*                    _pulldownSelectedImages;
}

@end

@implementation YDPlaylistViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = LOCALIZE(@"playlist");
        [self addObserver];
        
        _pulldownTitles = [NSArray arrayWithObjects:LOCALIZE(@"download_all"), LOCALIZE(@"clear_all"), nil];
        
        _pulldownImages = [NSArray arrayWithObjects:@"icon-header-download", @"icon-clear", nil];
        _pulldownSelectedImages = [NSArray arrayWithObjects:@"icon-header-download-h", @"icon-clear-h", nil];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    _tableData = [NSMutableArray arrayWithArray:[SINGLETON_CALL(InteractionManager) playlist]];
    _pulldown = [[RMEIdeasPullDownControl alloc] initWithDataSource:self delegate:self clientScrollView:_tableView];
    
    [self.view insertSubview:_pulldown belowSubview:_tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self showMenuBarItem:@selector(onMenuButtonPressed:)];
    [self showPlayingBarItem:@selector(onPlayingButtonPressed:)];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    [titleLabel setText:LOCALIZE(@"playlist")];
    [titleLabel sizeToFit];
    self.mm_drawerController.navigationItem.titleView = titleLabel;
    [self playlistUpdated];
}

- (void)dealloc {
    [self removeObserver];
}

- (void)addObserver {
}

- (void)removeObserver {
    [self unregisterAllNotify];
}

- (void)playlistUpdated {
    _tableData = [NSMutableArray arrayWithArray:[SINGLETON_CALL(InteractionManager) playlist]];
    [_tableView reloadData];
}

- (void)onMenuButtonPressed:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:NULL];
}

- (void)onPlayingButtonPressed:(id)sender {
    [self.mm_drawerController closeDrawerAnimated:YES completion:NULL];
    YDPlayingViewController* pvc = [[YDPlayingViewController alloc] initWithNibName:@"YDPlayingViewController" bundle:nil];
    [self.navigationController pushViewController:pvc animated:YES];
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
    [SINGLETON_CALL(InteractionManager) removeItemFromPlaylist:item];
    
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
    ArticleItem* item = ([_tableData count] > indexPath.row) ? [_tableData objectAtIndex:indexPath.row] : nil;
    
    [SINGLETON_CALL(InteractionManager) addItemToPlaylist:item first:YES];
    [SINGLETON_CALL(YDPlayer) restart];
    
    YDPlayingViewController* pvc = [[YDPlayingViewController alloc] initWithNibName:@"YDPlayingViewController" bundle:nil];
    [self.navigationController pushViewController:pvc animated:YES];
}

#pragma mark - RMEIdeasPullDownControlProtocol
- (void) rmeIdeasPullDownControl:(RMEIdeasPullDownControl*)rmeIdeasPullDownControl selectedControlAtIndex:(NSUInteger)controlIndex {
    
    SIAlertViewHandler handler = NULL;
    NSString* message = nil;
    switch (controlIndex) {
        case 0: {
            message = LOCALIZE(@"download_all_prompt");
            handler = ^(SIAlertView* alertView) {
                for (ArticleItem* article in _tableData) {
                    [SINGLETON_CALL(YDTaskManager) addTask:[YDTaskItem itemWithArticle:article]];
                }
            };
            break;
        }
        case 1: {
            message = LOCALIZE(@"clear_all_prompt");
            handler = ^(SIAlertView* alertView) {
                [SINGLETON_CALL(InteractionManager) removeAllItemsFromPlaylist];
            };
            break;
        }
        default:
            break;
    }
    
    SIAlertView* alertView = [[SIAlertView alloc] initWithTitle:LOCALIZE(@"message") andMessage:message];
    [alertView addButtonWithTitle:LOCALIZE(@"ok") type:SIAlertViewButtonTypeDefault handler:handler];
    [alertView addButtonWithTitle:LOCALIZE(@"cancel") type:SIAlertViewButtonTypeDefault handler:NULL];
    [alertView show];
    
}

#pragma mark - RMEIdeasPullDownControlDataSource
- (UIImage*) rmeIdeasPullDownControl:(RMEIdeasPullDownControl*)rmeIdeasPullDownControl imageForControlAtIndex:(NSUInteger)controlIndex {
    return IMG([_pulldownImages objectAtIndex:controlIndex]);
}

- (UIImage*) rmeIdeasPullDownControl:(RMEIdeasPullDownControl*)rmeIdeasPullDownControl selectedImageForControlAtIndex:(NSUInteger)controlIndex {
    return IMG([_pulldownSelectedImages objectAtIndex:controlIndex]);
}

- (NSString*) rmeIdeasPullDownControl:(RMEIdeasPullDownControl*)rmeIdeasPullDownControl titleForControlAtIndex:(NSUInteger)controlIndex {
    return [_pulldownTitles objectAtIndex:controlIndex];
}

- (NSUInteger) numberOfButtonsRequired:(RMEIdeasPullDownControl*)rmeIdeasPullDownControl {
    return [_pulldownTitles count];
}



@end
