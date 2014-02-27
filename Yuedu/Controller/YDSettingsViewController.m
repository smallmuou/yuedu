//
//  YDSettingsViewController.m
//  Yuedu
//
//  Created by xuwf on 13-10-29.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "YDSettingsViewController.h"
#import "YDPlayingViewController.h"

//keys
NSString* SettingsAutoDownloadKey = @"SettingsAutoDownloadKey";
NSString* SettingsAutoPlayKey = @"SettingsAutoPlayKey";
NSString* SettingsSleepTimerKey = @"SettingsSleepTimerKey";

@interface YDSettingsViewController () {
    NSArray* _sections;
    NSArray* _sleepTimes;
}

@end

@implementation YDSettingsViewController
- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray* preferences = [NSArray arrayWithObjects:LOCALIZE(@"preferences"),
                            @"icon-setting-autodownload", LOCALIZE(@"auto_download"),
                            @"icon-setting-autoplay", LOCALIZE(@"auto_play"),
                            @"icon-setting-sleeptimer", LOCALIZE(@"sleep_timer"),
                            @"icon-setting-cache", LOCALIZE(@"clean_history"),
                            nil];
    
    NSArray* abouts = [NSArray arrayWithObjects:LOCALIZE(@"about"),
                       @"icon-settings-about", LOCALIZE(@"version"),
                       nil];
    _sections = [NSArray arrayWithObjects:preferences, abouts, nil];
    _sleepTimes = [NSArray arrayWithObjects:
                   INT_NUMBER(15),
                   INT_NUMBER(30),
                   INT_NUMBER(60),
                   INT_NUMBER(120), nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self showMenuBarItem:@selector(onMenuButtonPressed:)];
    [self showPlayingBarItem:@selector(onPlayingButtonPressed:)];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    [titleLabel setText:LOCALIZE(@"settings")];
    [titleLabel sizeToFit];
    self.mm_drawerController.navigationItem.titleView = titleLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onMenuButtonPressed:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:NULL];
}

- (void)onPlayingButtonPressed:(id)sender {
    [self.mm_drawerController closeDrawerAnimated:NO completion:NULL];
    YDPlayingViewController* pvc = [[YDPlayingViewController alloc] initWithNibName:@"YDPlayingViewController" bundle:nil];
    [self.navigationController pushViewController:pvc animated:YES];
}


- (NSString* )stringWithTimeInterval:(NSInteger)interval {
    NSInteger min = interval/60;
    
    return (min > 0) ? [NSString stringWithFormat:@"%d min", min] : LOCALIZE(@"close");
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger row = ([[_sections objectAtIndex:section] count]-1)/2;
    return (row > 0) ? row : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSArray* array = [_sections objectAtIndex:indexPath.section];
    cell.imageView.image = IMG([array objectAtIndex:indexPath.row*2+1]);
    cell.textLabel.text = [array objectAtIndex:indexPath.row*2+2];
    
    if (0 == indexPath.section) {
        switch (indexPath.row) {
            case 0: {
                UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
                [button setImage:IMG(@"icon-setting-off") forState:UIControlStateNormal];
                [button setImage:IMG(@"icon-setting-on") forState:UIControlStateSelected];
                [button setSelected:[USER_CONFIG(SettingsAutoDownloadKey) boolValue]];
                cell.accessoryView = button;
                break;
            }
            case 1: {
                UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
                [button setImage:IMG(@"icon-setting-off") forState:UIControlStateNormal];
                [button setImage:IMG(@"icon-setting-on") forState:UIControlStateSelected];
                [button setSelected:[USER_CONFIG(SettingsAutoPlayKey) boolValue]];
                cell.accessoryView = button;
                break;
            }
            case 2: {
                UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
                [label setBackgroundColor:[UIColor clearColor]];
                label.font = [UIFont systemFontOfSize:16];
                label.textColor = [UIColor darkGrayColor];
                [label setText:[self stringWithTimeInterval:INT_VALUE(USER_CONFIG(SettingsSleepTimerKey))]];
                [label sizeToFit];
                cell.accessoryView = label;
                break;
            }
            case 3:
                break;
            default:
                break;
        }
    } else if (1 == indexPath.section) {
        switch (indexPath.row) {
            case 0: {
                UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
                [label setBackgroundColor:[UIColor clearColor]];
                label.font = [UIFont systemFontOfSize:16];
                label.textColor = [UIColor darkGrayColor];
                [label setText:VERSION()];
                [label sizeToFit];
                cell.accessoryView = label;
                break;
            }
            default:
                break;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section) {
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        switch (indexPath.row) {
            case 0: {
                UIButton* button = (UIButton*)cell.accessoryView;
                BOOL selected = !button.selected;
                [button setSelected:selected];
                USER_SET_CONFIG(SettingsAutoDownloadKey, BOOL_NUMBER(selected));
                break;
            }
            case 1: {
                UIButton* button = (UIButton*)cell.accessoryView;
                BOOL selected = !button.selected;
                [button setSelected:selected];
                USER_SET_CONFIG(SettingsAutoPlayKey, BOOL_NUMBER(selected));
                break;
            }
            case 2: {
                UILabel* label = (UILabel*)cell.accessoryView;
                NSTimeInterval seconds = INT_VALUE(USER_CONFIG(SettingsSleepTimerKey));
                seconds *= 2;
                if (seconds <= 0) {
                    seconds = 15*60;
                } else if (seconds > 240*60) {
                    seconds = 0;
                }
                [label setText:[self stringWithTimeInterval:seconds]];
                 USER_SET_CONFIG(SettingsSleepTimerKey, INT_NUMBER(seconds));
                [label sizeToFit];
                break;
            }
            case 3:
                break;
            default:
                break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 310, 40)];
    label.text = [[_sections objectAtIndex:section] firstObject];
    label.textColor = [UIColor darkGrayColor];
    label.font = [UIFont systemFontOfSize:14];
    
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [view addSubview:label];
    return view;
}

@end
