//
//  YDAppDelegate.m
//  Yuedu
//
//  Created by xuwf on 13-10-15.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "YDAppDelegate.h"
#import "YDHomeViewController.h"
#import "YDMenuViewController.h"
#import "YDBriefPlaylistViewController.h"

@interface YDAppDelegate () {
    MMDrawerController* _drawerController;
    NSTimer*            _saveTimer;
}

@end

@implementation YDAppDelegate
@synthesize drawerController = _drawerController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [LoggerManager logger];
    [SINGLETON_CALL(LanguageManager) setType:LanguageTypeSimpleChinese];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    /* Home */
    YDHomeViewController* hvc = [[YDHomeViewController alloc] initWithNibName:@"YDHomeViewController" bundle:nil];

    UINavigationController* hnvc = [[UINavigationController alloc] initWithRootViewController:hvc];
    hnvc.navigationBarHidden = YES;
    
    /* Menu */
    YDMenuViewController* lvc = [[YDMenuViewController alloc] initWithNibName:@"YDMenuViewController" bundle:nil];
    
    YDBriefPlaylistViewController* rvc = [[YDBriefPlaylistViewController alloc] initWithNibName:@"YDBriefPlaylistViewController" bundle:nil];
    
    _drawerController = [[MMDrawerController alloc] initWithCenterViewController:hnvc leftDrawerViewController:lvc rightDrawerViewController:rvc];
    
    UINavigationController* nvc = [[UINavigationController alloc] initWithRootViewController:_drawerController];
    
    [nvc.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav-bar"] forBarMetrics:UIBarMetricsDefault];
    nvc.view.layer.masksToBounds = YES;
    nvc.view.layer.cornerRadius = 5;
    
    [_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeBezelPanningCenterView];
    [_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];

    self.window.rootViewController = nvc;
    [self.window makeKeyAndVisible];
    
    
    [SINGLETON_CALL(YDTaskManager) load:^{
        if ([USER_CONFIG(SettingsAutoPlayKey) boolValue]) {
            [SINGLETON_CALL(YDPlayer) restart];
        }
    }];
    [SINGLETON_CALL(InteractionManager) requestForChannel:NULL];
    
    
    /* 30s保存一次 */
    _saveTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(cache) userInfo:nil repeats:YES];
    
    return YES;
}

- (void)cache {
    [SINGLETON_CALL(InteractionManager) cache];
    [SINGLETON_CALL(YDTaskManager) cache];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self cache];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark Remote-control event handling
- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [SINGLETON_CALL(YDPlayer) toggle];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [SINGLETON_CALL(YDPlayer) next];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [SINGLETON_CALL(YDPlayer) previous];
                break;
            default:
                break;
        }
    }
}

@end
