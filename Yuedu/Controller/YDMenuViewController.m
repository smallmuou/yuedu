//
//  YDMenuViewController.m
//  Yuedu
//
//  Created by xuwf on 13-10-16.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "YDMenuViewController.h"
#import "YDMenuItem.h"
#import "YDHomeViewController.h"
#import "YDPlaylistViewController.h"
#import "YDFavorViewController.h"
#import "YDTaskViewController.h"
#import "YDSettingsViewController.h"

enum {
    MenuIndexHome = 0,
    MenuIndexCategories,
    MenuIndexPlaylist,
    MenuIndexDownload,
    MenuIndexSettings,
};

@interface YDMenuViewController () <RATreeViewDataSource, RATreeViewDelegate> {
    RATreeView* _treeView;
    YDMenuItem* _categoriesItem;
    
    NSArray*    _treeData;
    NSArray*    _iconData;
    
    
    JSBadgeView*    _playlistBadgeView;
    JSBadgeView*    _favorBadgeView;
}

@end

@implementation YDMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self addObserver];

        
    }
    return self;
}

- (void)dealloc {
    [self removeObserver];
}

- (void)addObserver {
    [self registerNotify:ChannelDataUpdatedNotification selector:@selector(categoriesUpdate:)];
    [self registerNotify:PlaylistDataUpdatedNotifaction selector:@selector(playlistUpdated:)];
    [self registerNotify:FavorlistDataUpdatedNotifaction selector:@selector(favorUpdated:)];
}

- (void)removeObserver {
    [self unregisterAllNotify];
}

- (NSArray* )channelItems {
    NSArray* categories = [SINGLETON_CALL(InteractionManager) channels];
    NSMutableArray* array = [NSMutableArray array];
    for (ChannelItem* channel in categories) {
        YDMenuItem* item = [YDMenuItem dataObjectWithName:channel.name children:nil];
        item.data = channel;
        [array addObject:item];
    }
    return [NSArray arrayWithArray:array];
}

- (void)categoriesUpdate:(NSNotification* )notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        _categoriesItem.children = [self channelItems];
        [_treeView reloadData];        
    });
}

- (void)playlistUpdated:(NSNotification* )notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        _playlistBadgeView.hidden = NO;
    });
}

- (void)favorUpdated:(NSNotification* )notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        _favorBadgeView.hidden = NO;
    });    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = COLOR(20, 20, 20, 1);    
    
    /* Menu */
    YDMenuItem* item1 = [YDMenuItem dataObjectWithName:LOCALIZE(@"home") children:nil];
    YDMenuItem* item3 = [YDMenuItem dataObjectWithName:LOCALIZE(@"playlist") children:nil];
    YDMenuItem* item5 = [YDMenuItem dataObjectWithName:LOCALIZE(@"download") children:nil];
    YDMenuItem* item6 = [YDMenuItem dataObjectWithName:LOCALIZE(@"settings") children:nil];
    
    _categoriesItem = [YDMenuItem dataObjectWithName:LOCALIZE(@"categories") children:[self channelItems]];
    _treeData = [NSArray arrayWithObjects:item1, _categoriesItem, item3, item5, item6, nil];
    _iconData = [NSArray arrayWithObjects:@"icon-home", @"icon-categories", @"icon-playlist", @"icon-download", @"icon-settings", nil];
    
    RATreeView *treeView = [[RATreeView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    treeView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    treeView.separatorColor = [UIColor clearColor];
    
    treeView.delegate = self;
    treeView.dataSource = self;
    treeView.separatorStyle = RATreeViewCellSeparatorStyleSingleLine;

    [treeView reloadData];
    
    _treeView = treeView;
    [self.view addSubview:treeView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TreeView Delegate methods
- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    return 50;
}

- (NSInteger)treeView:(RATreeView *)treeView indentationLevelForRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    return 3 * treeNodeInfo.treeDepthLevel;
}

- (BOOL)treeView:(RATreeView *)treeView shouldExpandItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    return YES;
}

- (BOOL)treeView:(RATreeView *)treeView shouldItemBeExpandedAfterDataReload:(id)item treeDepthLevel:(NSInteger)treeDepthLevel
{
    return NO;
}

#pragma mark - RATreeViewDataSource
- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    NSUInteger index = [_treeData indexOfObject:item];
    UITableViewCell *cell = nil;
    if (index == NSNotFound) {
        YDSubMenuCell* subcell = [CustomViews customViewsWithTag:CustomViewSubMenuCell];
        subcell.iconView.image = IMG(@"icon-submenu");
        subcell.titleLabel.text = ((YDMenuItem *)item).name;
        cell = subcell;
    } else {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        [cell.imageView setImage:IMG([_iconData objectAtIndex:index])];
        cell.textLabel.text = ((YDMenuItem *)item).name;
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        if (index == MenuIndexPlaylist) {
            _playlistBadgeView = [[JSBadgeView alloc] initWithParentView:cell.imageView alignment:JSBadgeViewAlignmentTopRight];
            _playlistBadgeView.badgeTextFont = [UIFont boldSystemFontOfSize:10];
            _playlistBadgeView.badgeText = @" ";
            _playlistBadgeView.hidden = YES;
        }
    }
    UIView *selectionView = [[UIView alloc] init];
    selectionView.backgroundColor = COLOR(0, 0, 0, 1);
    cell.selectedBackgroundView = selectionView;
    

    return cell;
}

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return [_treeData count];
    }
    return [((YDMenuItem *)item).children count];
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item
{
    YDMenuItem *data = item;
    if (item == nil) {
        return [_treeData objectAtIndex:index];
    }
    return [data.children objectAtIndex:index];
}

- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo {
    [treeView deselectRowForItem:item animated:NO];
    
    NSUInteger index = [_treeData indexOfObject:item];
    if (index == NSNotFound) {
        [self presentHomeViewController:item title:((YDMenuItem *)item).name];
    } else {
        switch (index) {
            case MenuIndexHome:
                [self presentHomeViewController:item title:nil];
                break;
            case MenuIndexPlaylist:
                _playlistBadgeView.hidden = YES;
                [self presentPlaylistViewController];
                break;
            case MenuIndexDownload:
                [self presentTaskViewController];
                break;
            case MenuIndexSettings:
                [self presentSetttingsViewController];
                break;
            default:
                break;
        }
    }
}

- (void)presentHomeViewController:(YDMenuItem* )item title:(NSString* )title {
    ChannelItem* channel = (ChannelItem*)[((YDMenuItem* )item) data];
    YDHomeViewController* vc = (YDHomeViewController* )self.mm_drawerController.centerViewController.navigationController.topViewController;
    
    if ([vc isKindOfClass:[YDHomeViewController class]]) {
        [vc reloadWithOffset:channel.offset count:channel.count];
        [self.mm_drawerController closeDrawerAnimated:YES completion:NULL];
        vc.title = title;
    } else {
        vc = [[YDHomeViewController alloc] initWithNibName:@"YDHomeViewController" bundle:nil];
        [vc reloadWithOffset:channel.offset count:channel.count];
        vc.title = title;
        
        UINavigationController* nvc = [[UINavigationController alloc] initWithRootViewController:vc];
        nvc.navigationBarHidden = YES;
        [self.mm_drawerController setCenterViewController:nvc withCloseAnimation:YES completion:NULL];
    }    
}

- (void)presentPlaylistViewController {
    YDPlaylistViewController* vc = (YDPlaylistViewController* )self.mm_drawerController.centerViewController.navigationController.topViewController;
    if ([vc isKindOfClass:[YDPlaylistViewController class]]) {
        [self.mm_drawerController closeDrawerAnimated:YES completion:NULL];
    } else {
        vc = [[YDPlaylistViewController alloc] initWithNibName:@"YDPlaylistViewController" bundle:nil];
        UINavigationController* nvc = [[UINavigationController alloc] initWithRootViewController:vc];
        nvc.navigationBarHidden = YES;
        [self.mm_drawerController setCenterViewController:nvc withCloseAnimation:YES completion:NULL];
    }
}

- (void)presentTaskViewController {
    YDTaskViewController* vc = (YDTaskViewController* )self.mm_drawerController.centerViewController.navigationController.topViewController;
    if ([vc isKindOfClass:[YDPlaylistViewController class]]) {
        [self.mm_drawerController closeDrawerAnimated:YES completion:NULL];
    } else {
        vc = [[YDTaskViewController alloc] initWithNibName:@"YDTaskViewController" bundle:nil];
        UINavigationController* nvc = [[UINavigationController alloc] initWithRootViewController:vc];
        nvc.navigationBarHidden = YES;
        [self.mm_drawerController setCenterViewController:nvc withCloseAnimation:YES completion:NULL];
    }
}

- (void)presentSetttingsViewController {
    YDSettingsViewController* vc = (YDSettingsViewController* )self.mm_drawerController.centerViewController.navigationController.topViewController;
    if ([vc isKindOfClass:[YDPlaylistViewController class]]) {
        [self.mm_drawerController closeDrawerAnimated:YES completion:NULL];
    } else {
        vc = [[YDSettingsViewController alloc] initWithNibName:@"YDSettingsViewController" bundle:nil];
        UINavigationController* nvc = [[UINavigationController alloc] initWithRootViewController:vc];
        nvc.navigationBarHidden = YES;
        [self.mm_drawerController setCenterViewController:nvc withCloseAnimation:YES completion:NULL];
    }
}


@end
