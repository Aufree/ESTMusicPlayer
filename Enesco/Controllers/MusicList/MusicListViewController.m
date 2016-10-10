//
//  MusicListViewController.m
//  Enesco
//
//  Created by Aufree on 11/30/15.
//  Copyright © 2015 The EST Group. All rights reserved.
//

#import "MusicListViewController.h"
#import "MusicViewController.h"
#import "MusicListCell.h"
#import "MusicIndicator.h"
#import "MBProgressHUD.h"

@interface MusicListViewController () <MusicViewControllerDelegate, MusicListCellDelegate>
@property (nonatomic, strong) NSMutableArray *musicEntities;
@property (nonatomic, assign) NSInteger currentIndex;
@end

@implementation MusicListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.title = @"Music List";
    [self headerRefreshing];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self createIndicatorView];
}

# pragma mark - Custom right bar button item

- (void)createIndicatorView {
    MusicIndicator *indicator = [MusicIndicator sharedInstance];
    indicator.hidesWhenStopped = NO;
    indicator.tintColor = [UIColor redColor];
    
    if (indicator.state != NAKPlaybackIndicatorViewStatePlaying) {
        indicator.state = NAKPlaybackIndicatorViewStatePlaying;
        indicator.state = NAKPlaybackIndicatorViewStateStopped;
    } else {
        indicator.state = NAKPlaybackIndicatorViewStatePlaying;
    }
    
    [self.navigationController.navigationBar addSubview:indicator];
    
    UITapGestureRecognizer *tapInditator = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapIndicator)];
    tapInditator.numberOfTapsRequired = 1;
    [indicator addGestureRecognizer:tapInditator];
}

- (void)handleTapIndicator {
    MusicViewController *musicVC = [MusicViewController sharedInstance];
    if (musicVC.musicEntities.count == 0) {
        [self showMiddleHint:@"暂无正在播放的歌曲"];
        return;
    }
    musicVC.dontReloadMusic = YES;
    [self presentToMusicViewWithMusicVC:musicVC];
}

# pragma mark - Load data from server

- (void)headerRefreshing {
    NSDictionary *musicsDict = [self dictionaryWithContentsOfJSONString:@"music_list.json"];
    self.musicEntities = [MusicEntity arrayOfEntitiesFromArray:musicsDict[@"data"]].mutableCopy;
    [self.tableView reloadData];
}

- (NSDictionary *)dictionaryWithContentsOfJSONString:(NSString *)fileLocation {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileLocation stringByDeletingPathExtension] ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

# pragma mark - Tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MusicViewController *musicVC = [MusicViewController sharedInstance];
    musicVC.musicTitle = self.navigationItem.title;
    musicVC.musicEntities = _musicEntities;
    musicVC.specialIndex = indexPath.row;
    musicVC.delegate = self;
    [self presentToMusicViewWithMusicVC:musicVC];

    [self updatePlaybackIndicatorWithIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

# pragma mark - Jump to music view

- (void)presentToMusicViewWithMusicVC:(MusicViewController *)musicVC {
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:musicVC];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

# pragma mark - Update music indicator state

- (void)updatePlaybackIndicatorWithIndexPath:(NSIndexPath *)indexPath {
    for (MusicListCell *cell in self.tableView.visibleCells) {
        cell.state = NAKPlaybackIndicatorViewStateStopped;
    }
    MusicListCell *musicsCell = [self.tableView cellForRowAtIndexPath:indexPath];
    musicsCell.state = NAKPlaybackIndicatorViewStatePlaying;
}

- (void)updatePlaybackIndicatorOfCell:(MusicListCell *)cell {
    MusicEntity *music = cell.musicEntity;
    if (music.musicId == [[MusicViewController sharedInstance] currentPlayingMusic].musicId) {
        cell.state = NAKPlaybackIndicatorViewStateStopped;
        cell.state = [MusicIndicator sharedInstance].state;
    } else {
        cell.state = NAKPlaybackIndicatorViewStateStopped;
    }
}

- (void)updatePlaybackIndicatorOfVisisbleCells {
    for (MusicListCell *cell in self.tableView.visibleCells) {
        [self updatePlaybackIndicatorOfCell:cell];
    }
}

# pragma mark - Tableview datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 57;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _musicEntities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *musicListCell = @"musicListCell";
    MusicEntity *music = _musicEntities[indexPath.row];
    MusicListCell *cell = [tableView dequeueReusableCellWithIdentifier:musicListCell];
    cell.musicNumber = indexPath.row + 1;
    cell.musicEntity = music;
    cell.delegate = self;
    [self updatePlaybackIndicatorOfCell:cell];
    return cell;
}
         
# pragma mark - HUD
         
- (void)showMiddleHint:(NSString *)hint {
     UIView *view = [[UIApplication sharedApplication].delegate window];
     MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
     hud.userInteractionEnabled = NO;
     hud.mode = MBProgressHUDModeText;
     hud.labelText = hint;
     hud.labelFont = [UIFont systemFontOfSize:15];
     hud.margin = 10.f;
     hud.yOffset = 0;
     hud.removeFromSuperViewOnHide = YES;
     [hud hide:YES afterDelay:2];
}

@end
