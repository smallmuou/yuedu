//
//  YDPlayingViewController.m
//  Yuedu
//
//  Created by xuwf on 13-10-17.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "YDPlayingViewController.h"
#import "YDBriefPlaylistViewController.h"

@interface YDPlayingViewController () <UIWebViewDelegate> {
    ArticleItem*    _articleItem;
    UIView*         _containerView;
    UIScrollView*   _scrollView;
    UIImageView*    _imageView;
    UIWebView*      _webView;
    UILabel*        _titleLablel;
    UILabel*        _authorLabel;
    UIButton*       _playlistButton;
    UIButton*       _favorButton;
    UIButton*       _shareButton;
    
    YDSlider*       _slider;
    UIButton*       _prevButton;
    UIButton*       _nextButton;
    UIButton*       _playButton;
    UIButton*       _pauseButton;
    UIButton*       _downloadButton;
    UIButton*       _modeButton;
    UIView*         _lineView;
    
    YDPlayer*       _player;
    NSTimer*        _timer;
    BOOL            _updateProgressAble;
    
    UISwipeGestureRecognizer*   _swipeGesture;
}

@end

@implementation YDPlayingViewController
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize titleLablel = _titleLablel;
@synthesize authorLabel = _authorLabel;
@synthesize favorButton = _favorButton;
@synthesize shareButton = _shareButton;
@synthesize containerView = _containerView;
@synthesize slider = _slider;
@synthesize currentLabel = _currentLabel;
@synthesize durationLabel = _durationLabel;
@synthesize prevButton = _prevButton;
@synthesize nextButton = _nextButton;
@synthesize playButton = _playButton;
@synthesize pauseButton = _pauseButton;
@synthesize downloadButton = _downloadButton;
@synthesize modeButton = _modeButton;
@synthesize lineView = _lineView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _player = SINGLETON_CALL(YDPlayer);        
        [self addObserver];

    }
    return self;
}

- (void)dealloc {
    [self removeObserver];
    [_timer invalidate];
    _timer = nil;
}

- (void)addObserver {
    [_player addObserver:self forKeyPath:@"playStatus" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [_player addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)removeObserver {
    [_player removeObserver:self forKeyPath:@"playStatus" context:nil];
    [_player removeObserver:self forKeyPath:@"currentItem" context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"playStatus"]) {
        [self updateWithStatus];
    } else if ([keyPath isEqualToString:@"currentItem"]) {
        _articleItem = _player.currentItem;
        [self playingItemUpdated];
    }
}

- (void)playingItemUpdated {
    /* ImageView */
    [_imageView setImageWithURL:[NSURL URLWithString:[_articleItem.bgURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:IMG(@"thumb-default")];
    
    [_titleLablel setText:_articleItem.title];

    _authorLabel.text = [NSString stringWithFormat:@"%@: %@   %@: %@", LOCALIZE(@"author"), _articleItem.author, LOCALIZE(@"player"), _articleItem.player];
    
    /* webView */
    [_webView removeFromSuperview];
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 211, self.scrollView.width-20, self.scrollView.height-211)];
    _webView.userInteractionEnabled = NO;
    _webView.delegate = self;
    [_webView setBackgroundColor:[UIColor clearColor]];
    for (UIView *subView in [_webView subviews]) {
        if ([subView isKindOfClass:[UIScrollView class]]) {
            for (UIView *shadowView in [subView subviews]) {
                if ([shadowView isKindOfClass:[UIImageView class]]) {
                    shadowView.hidden = YES;
                }
            }
        }
    }
    [self.scrollView addSubview:_webView];
    _scrollView.contentOffset = CGPointMake(0, 0);
    [SINGLETON_CALL(InteractionManager) requestDetailForArticle:_articleItem completion:^(BOOL success, id result) {
        [_webView loadHTMLString:result baseURL:nil];
    }];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    //NavigationBar
    _playlistButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 41, 30)];
    [_playlistButton setImage:IMG(@"bb-playlist") forState:UIControlStateNormal];
    [_playlistButton addTarget:self action:@selector(onPlaylistButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* barButton = [[UIBarButtonItem alloc] initWithCustomView:_playlistButton];
    self.mm_drawerController.navigationItem.rightBarButtonItem = barButton;
    
    _articleItem = _player.currentItem;
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:IMG(@"nav-logo")];
    
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [backButton setBackgroundImage:[IMG(@"bbback") resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 10)] forState:UIControlStateNormal];
    [backButton setTitle:LOCALIZE(@"back") forState:UIControlStateNormal];
    [backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    [backButton sizeToFit];
    [backButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [backButton addTarget:self action:@selector(onBackButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.mm_drawerController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    [self showLogoView];
    
    _lineView.width = 0;
    _authorLabel.numberOfLines = 2;
    
    /* ImageView */
    _containerView.layer.masksToBounds = YES;
    _containerView.layer.cornerRadius = 5;
    _titleLablel.numberOfLines = 2;
    
    [self playingItemUpdated];
    
    /* slider */
    [_slider setThumbImage:IMG(@"player-progress-point") forState:UIControlStateNormal];
    [_slider setThumbImage:IMG(@"player-progress-point-h") forState:UIControlStateHighlighted];
    [_slider setMinimumTrackImage:[IMG(@"player-progress-h") resizableImageWithCapInsets:UIEdgeInsetsMake(4, 3, 5, 4)]];
    [_slider setMiddleTrackImage:[IMG(@"player-progress-loading") resizableImageWithCapInsets:UIEdgeInsetsMake(4, 3, 5, 4)]];
    [_slider setMaximumTrackImage:[IMG(@"player-progress") resizableImageWithCapInsets:UIEdgeInsetsMake(4, 3, 5, 4)]];
    
    _swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognizer:)];
    _swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.scrollView addGestureRecognizer:_swipeGesture];
    
    [_currentLabel setText:[NSString stringWithSeconds:0]];
    [_durationLabel setText:[NSString revertStringWithSeconds:0]];
    [self updateWithStatus];
    [self updatePlayMode];
    
    _updateProgressAble = YES;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
    
}

- (void)swipeGestureRecognizer:(UISwipeGestureRecognizer* )gesture {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateWithStatus {
    switch (_player.playStatus) {
        case PlayStatusPlay:
            _updateProgressAble = YES;
            _pauseButton.hidden = NO;
            _playButton.hidden = YES;
            break;
        case PlayStatusPause:
            _updateProgressAble = NO;
            _pauseButton.hidden = YES;
            _playButton.hidden = NO;
            break;
        case PlayStatusStop:
            _updateProgressAble = NO;
            _pauseButton.hidden = YES;
            _playButton.hidden = NO;
            [_currentLabel setText:[NSString stringWithSeconds:0]];
            [_durationLabel setText:[NSString revertStringWithSeconds:_player.duration]];
            _slider.value = 0;
            break;
        case PlayStatusUnknown:
            _updateProgressAble = NO;
            _pauseButton.hidden = YES;
            _playButton.hidden = NO;
            _slider.value = 0;
            _slider.middleValue = 0;
            [_currentLabel setText:[NSString stringWithSeconds:0]];
            [_durationLabel setText:[NSString revertStringWithSeconds:0]];
            break;
        default:
            break;
    }
}

- (void)updatePlayMode {
    UIImage* image = nil;
    switch (_player.playMode) {
        case PlayModeOrder:
            image = IMG(@"player-order");
            break;
        case PlayModeRepeatOne:
            image = IMG(@"player-repeatone");
            break;
        case PlayModeShuffle:
            image = IMG(@"player-shuffle");
            break;
        default:
            break;
    }
    if (image) [_modeButton setImage:image forState:UIControlStateNormal];
}

- (void)onPlaylistButtonPressed:(id)sender {
    [__appDelegate.drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:NULL];
}

- (void)onBackButtonPressed:(id)sender {
    [self.mm_drawerController closeDrawerAnimated:YES completion:NULL];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadingAnimation {
    _lineView.width = 0;
    [UIView animateWithDuration:0.5f animations:^{
        _lineView.width = self.view.width;
    } completion:^(BOOL finished) {
        _lineView.width = 0;
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
}

- (void)updateProgress:(NSTimer* )timer {
    NSTimeInterval duration = _player.duration;
    NSTimeInterval available = _player.available;
    if (_updateProgressAble) {
        NSTimeInterval current = _player.current;
        _slider.value = duration ? current/duration : 0;
        
        [_currentLabel setText:[NSString stringWithSeconds:current]];
        [_durationLabel setText:[NSString revertStringWithSeconds:(duration-current)]];
    }
    
    _slider.middleValue = duration ? available/duration : 0;
}

- (IBAction)onSliderValueChanged:(id)sender {
    _updateProgressAble = NO;
}

- (IBAction)onSliderTouchUpInside:(id)sender {
    CGFloat seekSeconds = _player.duration*_slider.value;
    [_player seek:seekSeconds completion:^(BOOL finished) {
        _updateProgressAble = finished;
    }];
}


- (IBAction)onFavorButtonPressed:(id)sender {
}

- (IBAction)onShareButtonPressed:(id)sender {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    webView.height = webView.scrollView.contentSize.height;
    _scrollView.contentSize = CGSizeMake(self.view.width, webView.top+webView.height);
}


- (IBAction)onPrevButtonPressed:(id)sender {
    [_player previous];
    [self loadingAnimation];    
}

- (IBAction)onNextButtonPressed:(id)sender {
    [_player next];
    [self loadingAnimation];
}

- (IBAction)onPlayButtonPressed:(id)sender {
    [self loadingAnimation];
    [_player resume];
}

- (IBAction)onPauseButtonPressed:(id)sender {
    [self loadingAnimation];
    [_player pause];
}

- (IBAction)onDownloadButtonPressed:(id)sender {
    [SINGLETON_CALL(YDTaskManager) addTask:[YDTaskItem itemWithArticle:_articleItem]];
}

- (IBAction)onModeButtonPressed:(id)sender {
    _player.playMode = (_player.playMode+1)%PlayModeMax;
    [self updatePlayMode];
}

@end
