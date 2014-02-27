//
//  YDHomeViewController.m
//  Yuedu
//
//  Created by xuwf on 13-10-16.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "YDHomeViewController.h"
#import "YDPlayingViewController.h"

@interface YDHomeViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, EGORefreshTableHeaderDelegate> {
    UITableView*    _tableView;
    NSArray*        _tableData;
    LeoLoadingView* _loadingView;
    UISearchBar*    _searchBar;
    UIButton*       _dismissKeyBoardButton;
    BOOL            _shouldBeginEditing;
    BOOL            _allowUpdate;
    
    NSUInteger      _offset;
    NSUInteger      _count;
    NSString*       _filterText;
    
    NSInteger       _badgeCount;
    JSBadgeView*    _badgeView;
    
    EGORefreshTableHeaderView* _refreshHeaderView;
    BOOL                _loading;

}
@property (nonatomic, strong) UISearchBar* searchBar;
@end

@implementation YDHomeViewController
@synthesize tableView = _tableView;
@synthesize loadingView = _loadingView;
@synthesize searchBar = _searchBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [self removeObserver];
}

- (void)addObserver {
    [self registerNotify:ArticleListDataUpdatedNotification selector:@selector(articleListUpdated:)];
}

- (void)removeObserver {
    [self unregisterAllNotify];
}

- (NSArray* )articles {
    NSArray* articles = [SINGLETON_CALL(InteractionManager) articles];
    if (_count) {
        articles = [articles subarrayWithRange:NSMakeRange(_offset, _count)];
    }
    
    if (_filterText && ![_filterText isEqualToString:@""]) {
        NSPredicate* filter = [NSPredicate predicateWithFormat:@"SELF.title CONTAINS[c] %@ OR SELF.author CONTAINS[c] %@ OR SELF.player CONTAINS[c] %@", _filterText, _filterText, _filterText];
        articles = [articles filteredArrayUsingPredicate:filter];
    }
    return articles;
}

- (void)reloadWithOffset:(NSUInteger)offset count:(NSUInteger)count {
    _offset = offset;
    _count = count;
    
    _tableData = [self articles];
    [self.tableView reloadData];
}

- (void)articleListUpdated:(NSNotification* )notification {
    if (_allowUpdate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadWithOffset:_offset count:_count];
        });        
    }
}

- (void)listArticle {
    if (_loading) return;
    _loading = YES;
    
    [_loadingView showView:_loading];
    [SINGLETON_CALL(InteractionManager) requestForArticleList:^(BOOL success, id result) {
        _loading = NO;
        [_loadingView showView:_loading];
        _tableView.tableHeaderView = _searchBar;
        [self resetTableViewOffset:NO];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _badgeCount = 0;
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    [self.searchBar setPlaceholder:@"Search & Explorer"];
    [self.searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"searchbar-bg"] forState:UIControlStateNormal];
    self.searchBar.tintColor = [UIColor colorWithWhite:1 alpha:1];
    self.searchBar.delegate = self;
    self.searchBar.layer.borderWidth = 1;
    self.searchBar.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    [self.searchBar sizeToFit];
    
    /* Refraesh */
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithScrollView:self.tableView orientation:EGOPullOrientationDown];
    _refreshHeaderView.delegate = self;
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [self reloadWithOffset:_offset count:_count];
    
    [_loadingView showView:NO];
    if (![[SINGLETON_CALL(InteractionManager) articles] count]) {
        [self listArticle];
    } else {
        _tableView.tableHeaderView = _searchBar;
        [self resetTableViewOffset:NO];
    }
    
    [self addObserver];
    _allowUpdate = YES;
}

- (void)resetTableViewOffset:(BOOL)animated {
    if (!_tableView.tableHeaderView) return;
    
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            _tableView.contentOffset = CGPointMake(0, CGRectGetHeight(_searchBar.bounds));
        }];
    } else {
        _tableView.contentOffset = CGPointMake(0, CGRectGetHeight(_searchBar.bounds));
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self showMenuBarItem:@selector(onMenuButtonPressed:)];
    if (self.title) {
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        [titleLabel setText:self.title];
        [titleLabel sizeToFit];
        self.mm_drawerController.navigationItem.titleView = titleLabel;
    } else {
        [self showLogoView];
    }
    [self showPlayingBarItem:@selector(onPlayingButtonPressed:)];
    
    UIView* v = self.mm_drawerController.navigationItem.leftBarButtonItem.customView;
    JSBadgeView* badge = [[JSBadgeView alloc] initWithParentView:v alignment:JSBadgeViewAlignmentTopRight];
    badge.badgeTextFont = [UIFont boldSystemFontOfSize:10];
    badge.badgePositionAdjustment = CGPointMake(-5, 8);
    badge.badgeText = _badgeView.badgeText;
    _badgeView = badge;
    
    [self resetTableViewOffset:NO];
}

- (void)onMenuButtonPressed:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:NULL];
}

- (void)onPlayingButtonPressed:(id)sender {
    [self.mm_drawerController closeDrawerAnimated:YES completion:NULL];
    YDPlayingViewController* pvc = [[YDPlayingViewController alloc] initWithNibName:@"YDPlayingViewController" bundle:nil];
    [self.navigationController pushViewController:pvc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - search bar delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    BOOL ret = _shouldBeginEditing;
    _shouldBeginEditing = YES;

    return ret;
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    UIView* superView = [searchBar superview];
    
    _dismissKeyBoardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _dismissKeyBoardButton.backgroundColor = [UIColor clearColor];
    _dismissKeyBoardButton.frame = [superView bounds];
    if ([superView isKindOfClass:[UIScrollView class]]) {
        _dismissKeyBoardButton.height = ((UIScrollView* )superView).contentSize.height;
    }
    
    _dismissKeyBoardButton.userInteractionEnabled = YES;
    [_dismissKeyBoardButton addTarget:self action:@selector(dismissKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    [superView addSubview:_dismissKeyBoardButton];
    [superView bringSubviewToFront:_searchBar];
}

- (void)dismissKeyboard:(id)sender {
    _tableView.userInteractionEnabled = YES;
    [_searchBar resignFirstResponder];
    [_dismissKeyBoardButton removeFromSuperview];
    _dismissKeyBoardButton = nil;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *) searchBar {
    _tableView.userInteractionEnabled = YES;
    [_dismissKeyBoardButton removeFromSuperview];
    _dismissKeyBoardButton = nil;
    [self resetTableViewOffset:YES];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _filterText = searchText;
    _tableData = [self articles];
    [_tableView reloadData];
}

#pragma mark - Animation
- (void)animationDidStop:(CALayer* )layer {
    [layer removeFromSuperlayer];
}

- (void)playlistAddAnimation:(UIButton* )button {
    UIWindow* keyWindow = [[UIApplication sharedApplication] keyWindow];
    [button setImage:IMG(@"button-playlistremove") forState:UIControlStateNormal];

    CALayer* animationLayer = [CALayer layer];
    animationLayer.backgroundColor = [UIColor clearColor].CGColor;
    animationLayer.contents = (id)button.imageView.image.CGImage;
    animationLayer.frame = [keyWindow convertRect:button.bounds fromView:button];
    [keyWindow.layer addSublayer:animationLayer];
    
    UIBezierPath *movePath = [UIBezierPath bezierPath];
    CGPoint start = CGPointMake(CGRectGetMidX(animationLayer.frame), CGRectGetMidY(animationLayer.frame));
    CGPoint end = CGPointMake(30, 40);

    [movePath moveToPoint:start];
    [movePath addQuadCurveToPoint:end
                     controlPoint:CGPointMake(start.x*1,start.y*0.25)];
    //关键帧
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.path = movePath.CGPath;
    positionAnimation.removedOnCompletion = NO;
    
    CABasicAnimation* scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = FLOAT_NUMBER(1);
    scaleAnimation.toValue = FLOAT_NUMBER(0.5);
    
    CABasicAnimation* rotaionAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotaionAnimation.fromValue = FLOAT_NUMBER(0);
    rotaionAnimation.toValue = FLOAT_NUMBER(3.14*2);
    
    CAAnimationGroup* groupAnimation = [CAAnimationGroup animation];
    groupAnimation.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, rotaionAnimation, nil];
    groupAnimation.duration = 0.3;
    
    [animationLayer addAnimation:groupAnimation forKey:@"position"];
    [self performSelector:@selector(animationDidStop:) withObject:animationLayer afterDelay:0.35];
}

- (void)playlistRemoveAnimation:(UIButton* )button {
    UIWindow* keyWindow = [[UIApplication sharedApplication] keyWindow];
    CALayer* animationLayer = [CALayer layer];
    animationLayer.backgroundColor = [UIColor clearColor].CGColor;
    animationLayer.contents = (id)button.imageView.image.CGImage;
    animationLayer.frame = [keyWindow convertRect:button.bounds fromView:button];
    [keyWindow.layer addSublayer:animationLayer];
    
    UIBezierPath *movePath = [UIBezierPath bezierPath];
    CGPoint start = CGPointMake(CGRectGetMidX(animationLayer.frame), CGRectGetMidY(animationLayer.frame));
    CGPoint end = CGPointMake(40, 40);
    [movePath moveToPoint:end];
    [movePath addQuadCurveToPoint:start
                     controlPoint:CGPointMake(start.x*1,start.y*0.25)];


    //关键帧
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.path = movePath.CGPath;
    positionAnimation.removedOnCompletion = NO;
    
    CABasicAnimation* scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = FLOAT_NUMBER(0.5);
    scaleAnimation.toValue = FLOAT_NUMBER(1);
    
    CABasicAnimation* rotaionAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotaionAnimation.fromValue = FLOAT_NUMBER(0);
    rotaionAnimation.toValue = FLOAT_NUMBER(3.14*2);
    
    CAAnimationGroup* groupAnimation = [CAAnimationGroup animation];
    groupAnimation.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, rotaionAnimation, nil];
    groupAnimation.duration = 0.3;
    
    [button setImage:IMG(@"button-playlistadd") forState:UIControlStateNormal];
    [animationLayer addAnimation:groupAnimation forKey:@"position"];
    [self performSelector:@selector(animationDidStop:) withObject:animationLayer afterDelay:0.35];
}

- (void)onAddButtonPressed:(UITableViewCell* )cell {
    _allowUpdate = NO;
    NSIndexPath* indexPath = [_tableView indexPathForCell:cell];
    YDArticleCell* aCell = (YDArticleCell* )cell;
    
    if (_tableData.count <= indexPath.row) return;
    
    ArticleItem* item = [_tableData objectAtIndex:indexPath.row];
    item.existOnPlaylist = !item.existOnPlaylist;
    
    if (!item.existOnPlaylist) {
        [self playlistRemoveAnimation:aCell.addButton];
        _badgeCount--;
        [SINGLETON_CALL(InteractionManager) removeItemFromPlaylist:item];
    } else {
        [self playlistAddAnimation:aCell.addButton];
        _badgeCount++;
        [SINGLETON_CALL(InteractionManager) addItemToPlaylist:item first:NO];
    }
    
    if (_badgeCount > 99) {
        _badgeView.badgeText = [NSString stringWithFormat:@"99+"];
    } else if (_badgeCount > 0) {
        _badgeView.badgeText = [NSString stringWithFormat:@"%d", _badgeCount];
    } else {
        _badgeCount = 0;
        _badgeView.badgeText = @"";
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    _allowUpdate = YES;
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
    
    UIImage* image = item.existOnPlaylist ? IMG(@"button-playlistremove") : IMG(@"button-playlistadd");
    [cell.addButton setImage:image forState:UIControlStateNormal];
    [cell addTargetForAddButton:self action:@selector(onAddButtonPressed:)];

    
    return cell;
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

#pragma mark - EGORefreshTableHeaderDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)egoRefreshTableHeaderRefreshDone {
    [self listArticle];
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self performSelector:@selector(egoRefreshTableHeaderRefreshDone) withObject:nil afterDelay:1.0f];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _loading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate date]; // should return date data source was last changed
	
}

@end
