//
//  YDTaskViewController.m
//  Yuedu
//
//  Created by xuwf on 13-10-29.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "YDTaskViewController.h"
#import "YDPlayingViewController.h"

@interface YDTaskViewController () <UITableViewDataSource, UITableViewDelegate, RMEIdeasPullDownControlProtocol, RMEIdeasPullDownControlDataSource> {
    UITableView*    _tableView;
    NSMutableArray* _undoneTasks;
    NSMutableArray* _doneTasks;
    YDTaskManager*  _taskManager;
    
    RMEIdeasPullDownControl*    _pulldown;
    NSArray*                    _pulldownTitles;
    NSArray*                    _pulldownImages;
    NSArray*                    _pulldownSelectedImages;
}

@end

@implementation YDTaskViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _taskManager = SINGLETON_CALL(YDTaskManager);
        [self addObserver];
        
        _pulldownTitles = [NSArray arrayWithObjects:LOCALIZE(@"clear_downloading"), LOCALIZE(@"clear_downloaded"), LOCALIZE(@"clear_all"), nil];
        
        _pulldownImages = [NSArray arrayWithObjects:@"icon-clear-downloading", @"icon-clear-downloaded", @"icon-clear", nil];
        _pulldownSelectedImages = [NSArray arrayWithObjects:@"icon-clear-downloading-h", @"icon-clear-downloaded-h", @"icon-clear-h", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _doneTasks = [NSMutableArray arrayWithArray:_taskManager.doneTasks];
    _undoneTasks = [NSMutableArray arrayWithArray:_taskManager.undoneTasks];
    
    _pulldown = [[RMEIdeasPullDownControl alloc] initWithDataSource:self delegate:self clientScrollView:_tableView];
    
    [self.view insertSubview:_pulldown belowSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self showMenuBarItem:@selector(onMenuButtonPressed:)];
    [self showPlayingBarItem:@selector(onPlayingButtonPressed:)];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    [titleLabel setText:LOCALIZE(@"download")];
    [titleLabel sizeToFit];
    self.mm_drawerController.navigationItem.titleView = titleLabel;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addObserver {
    [_taskManager addObserver:self forKeyPath:@"doneTasks" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [_taskManager addObserver:self forKeyPath:@"undoneTasks" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    [self registerNotify:YDTaskManagerTaskDidUpdated selector:@selector(taskDidUpdated:)];
}

- (void)taskDidUpdated:(NSNotification* )notification {
    YDTaskItem* task = [notification object];
    NSIndexPath* indexPath;
    
    if ([_undoneTasks containsObject:task]) {
        indexPath = [NSIndexPath indexPathForRow:[_undoneTasks indexOfObject:task] inSection:0];
    } else if ([_doneTasks containsObject:task]) {
        indexPath = [NSIndexPath indexPathForRow:[_doneTasks indexOfObject:task] inSection:1];
    }
    
    [_tableView reloadRowsAtIndexPaths:ARRAY(indexPath) withRowAnimation:UITableViewRowAnimationNone];
}

- (void)dealloc {
    [self removeObserver];
}


- (void)removeObserver {
    [_taskManager removeObserver:self forKeyPath:@"doneTasks" context:nil];
    [_taskManager removeObserver:self forKeyPath:@"undoneTasks" context:nil];
    [self unregisterAllNotify];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"doneTasks"]) {
        _doneTasks = [NSMutableArray arrayWithArray:_taskManager.doneTasks];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    } else if ([keyPath isEqualToString:@"undoneTasks"]) {
        _undoneTasks = [NSMutableArray arrayWithArray:_taskManager.undoneTasks];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];

    }
}

- (void)onMenuButtonPressed:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:NULL];
}

- (void)onPlayingButtonPressed:(id)sender {
    [self.mm_drawerController closeDrawerAnimated:NO completion:NULL];
    YDPlayingViewController* pvc = [[YDPlayingViewController alloc] initWithNibName:@"YDPlayingViewController" bundle:nil];
    [self.navigationController pushViewController:pvc animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSMutableArray* )arrayInSection:(NSInteger)section {
    if (section == 0) {
        return _undoneTasks;
    } else {
        return _doneTasks;
    }
}

- (NSString* )titleInSection:(NSInteger)section {
    if (section == 0) {
        return LOCALIZE(@"downloading");
    } else {
        return LOCALIZE(@"downloaded");
    }    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self arrayInSection:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* identifier = @"TaskCell";
    YDTaskCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [CustomViews customViewsWithTag:CustomViewTaskCell];
    }


    YDTaskItem* task = [[self arrayInSection:indexPath.section] objectAtIndex:indexPath.row];
    ArticleItem* item = task.article;
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

    cell.progressView.left = task.progress*cell.width;
    return cell;
}

- (void)onAddButtonPressed:(UITableViewCell* )cell {
    NSIndexPath* indexPath = [_tableView indexPathForCell:cell];
    NSMutableArray* array = [self arrayInSection:indexPath.section];
    YDTaskItem* item = [array objectAtIndex:indexPath.row];
    [_taskManager removeTask:item];
    
    [array removeObject:item];
    [_tableView beginUpdates];
    [_tableView deleteRowsAtIndexPaths:ARRAY(indexPath) withRowAnimation:UITableViewRowAnimationFade];
    [_tableView endUpdates];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSMutableArray* array = [self arrayInSection:section];
    if (![array count]) return 0;
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    YDSectionHeaderView* view = [CustomViews customViewsWithTag:CustomViewTaskSectionHeader];
    view.titleLabel.text = [self titleInSection:section];
    if (1 == section) {
        view.addButton.hidden = NO;
        [view.addButton addTarget:self action:@selector(onSectionAddButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return view;
}

- (void)onSectionAddButtonPressed:(UIButton* )button {
    for (YDTaskItem* task in _doneTasks) {
        [SINGLETON_CALL(InteractionManager) addItemToPlaylist:task.article first:NO];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    return view;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YDTaskItem* task = [[self arrayInSection:indexPath.section] objectAtIndex:indexPath.row];
    ArticleItem* item = task.article;
    
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
            message = LOCALIZE(@"clear_downloading_prompt");
            handler = ^(SIAlertView* alertView) {
                [_taskManager removeUndoneTasks];
            };
            break;
        }
        case 1: {
            message = LOCALIZE(@"clear_downloaded_prompt");
            handler = ^(SIAlertView* alertView) {
                [_taskManager removeDoneTasks];
            };
            break;
        }
        case 2: {
            message = LOCALIZE(@"clear_all_prompt");
            handler = ^(SIAlertView* alertView) {
                [_taskManager removeAllTasks];
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
