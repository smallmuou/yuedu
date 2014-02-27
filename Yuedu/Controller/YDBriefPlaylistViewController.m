//
//  YDBriefPlaylistViewController.m
//  Yuedu
//
//  Created by xuwf on 13-10-26.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "YDBriefPlaylistViewController.h"

@interface YDBriefPlaylistViewController () <UITableViewDataSource, UITableViewDelegate> {
    UITableView*    _tableView;
    NSArray*        _tableData;
    YDPlayer*       _player;
}

@end

@implementation YDBriefPlaylistViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = COLOR(20, 20, 20, 1);
    _player = SINGLETON_CALL(YDPlayer);
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableData = _player.playlist;
    [self addObserver];
}

- (void)addObserver {
    [_player addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [_player addObserver:self forKeyPath:@"playlist" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)dealloc {
    [self removeObserver];
}


- (void)removeObserver {
    [_player removeObserver:self forKeyPath:@"currentItem" context:nil];
    [_player removeObserver:self forKeyPath:@"playlist" context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentItem"]) {
        NSUInteger row = [_tableData indexOfObject:_player.currentItem];
        if (row != NSNotFound) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [_tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
    } else if ([keyPath isEqualToString:@"playlist"]) {
        _tableData = _player.playlist;
        [self.tableView reloadData];
    }
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
    static NSString* identifier = @"BriefArticleCell";
    YDBriefArticleCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [CustomViews customViewsWithTag:CustomViewBriefArticleCell];
        cell.thumbView.layer.masksToBounds = YES;
        cell.thumbView.layer.cornerRadius = 3;
        UIView *selectionView = [[UIView alloc] init];
        selectionView.backgroundColor = [UIColor blackColor];
        cell.selectedBackgroundView = selectionView;
    }
    
    ArticleItem* item = [_tableData objectAtIndex:indexPath.row];    
    [cell.thumbView setImageWithURL:[NSURL URLWithString:[item.thumbURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                   placeholderImage:IMG(@"thumb-default")];
    [cell.titleLabel setText:[NSString stringWithFormat:@"%d. %@ - %@", indexPath.row+1, item.title, item.player]];
    cell.durationLabel.text = item.duration;
    
    NSUInteger index = [_tableData indexOfObject:_player.currentItem];
    if (index == indexPath.row) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
        
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_player playWithIndex:indexPath.row];
}

@end
