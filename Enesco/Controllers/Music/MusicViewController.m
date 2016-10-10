//
//  MusicViewController.m
//  Enesco
//
//  Created by Aufree on 11/30/15.
//  Copyright © 2015 The EST Group. All rights reserved.
//

#import "MusicViewController.h"
#import "MusicSlider.h"
#import "MusicHandler.h"

#import "Track.h"
#import "MusicIndicator.h"
#include <stdlib.h>

#import "UIView+Animations.h"
#import "NSString+Additions.h"
#import "MBProgressHUD.h"

static void *kStatusKVOKey = &kStatusKVOKey;
static void *kDurationKVOKey = &kDurationKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;

@interface MusicViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *albumImageLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *albumImageRightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *musicMenuButton;
@property (weak, nonatomic) IBOutlet MusicSlider *musicSlider;
@property (weak, nonatomic) IBOutlet UIImageView *backgroudImageView;
@property (weak, nonatomic) IBOutlet UIView *backgroudView;
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;
@property (weak, nonatomic) IBOutlet UILabel *musicNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UILabel *musicTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *beginTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *previousMusicButton;
@property (weak, nonatomic) IBOutlet UIButton *nextMusicButton;
@property (weak, nonatomic) IBOutlet UIButton *musicToggleButton;
@property (weak, nonatomic) IBOutlet UIButton *musicCycleButton;
@property (strong, nonatomic) MusicEntity *musicEntity;
@property (strong, nonatomic) UIVisualEffectView *visualEffectView;
@property (strong, nonatomic) MusicIndicator *musicIndicator;
@property (strong, nonatomic) NSMutableArray *originArray;
@property (strong, nonatomic) NSMutableArray *randomArray;
@property (strong, nonatomic) NSMutableString *lastMusicUrl;

@property (nonatomic) NSTimer *musicDurationTimer;
@property (nonatomic) BOOL musicIsPlaying;
@property (nonatomic) NSInteger currentIndex;
@end

@implementation MusicViewController

+ (instancetype)sharedInstance {
    static MusicViewController *_sharedMusicVC = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMusicVC = [[UIStoryboard storyboardWithName:@"Music" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"music"];
        _sharedMusicVC.streamer = [[DOUAudioStreamer alloc] init];
    });
    
    return _sharedMusicVC;
}

# pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self adapterIphone4];
    _musicDurationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSliderValue:) userInfo:nil repeats:YES];
    _currentIndex = 0;
    _musicIndicator = [MusicIndicator sharedInstance];
    _originArray = @[].mutableCopy;
    _randomArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self addPanRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    _musicCycleType = [GVUserDefaults standardUserDefaults].musicCycleType;
    [self setupRadioMusicIfNeeded];
    
    if (_dontReloadMusic && _streamer) {
        return;
    }
    _currentIndex = 0;
    
    [_originArray removeAllObjects];
    [self loadOriginArrayIfNeeded];
    
    [self createStreamer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    _dontReloadMusic = YES;
}

- (void)loadOriginArrayIfNeeded {
    if (_originArray.count == 0) {
        for (int i = 0; i < _musicEntities.count; i++) {
            [_originArray addObject:[NSNumber numberWithInt:i]];
        }
        NSNumber *currentNum = [NSNumber numberWithInteger:_currentIndex];
        if ([_originArray containsObject:currentNum]) {
            [_originArray removeObject:currentNum];
        }
    }
}

# pragma mark - Basic setup

- (void)adapterIphone4 {
    if (IS_IPHONE_4_OR_LESS) {
        CGFloat margin = 65;
        _albumImageLeftConstraint.constant = margin;
        _albumImageRightConstraint.constant = margin;
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    [self setupMusicViewWithMusicEntity:_musicEntities[currentIndex]];
}

- (void)setupMusicViewWithMusicEntity:(MusicEntity *)entity {
    _musicEntity = entity;
    _musicNameLabel.text = _musicEntity.name;
    _singerLabel.text = _musicEntity.artistName;
    _musicTitleLabel.text = _musicTitle;
    [self setupBackgroudImage];
    [self checkMusicFavoritedIcon];
}

- (void)setMusicCycleType:(MusicCycleType)musicCycleType {
    _musicCycleType = musicCycleType;
    [self updateMusicCycleButton];
}

- (void)updateMusicCycleButton {
    switch (_musicCycleType) {
        case MusicCycleTypeLoopAll:
            [_musicCycleButton setImage:[UIImage imageNamed:@"loop_all_icon"] forState:UIControlStateNormal];
            break;
        case MusicCycleTypeShuffle:
            [_musicCycleButton setImage:[UIImage imageNamed:@"shuffle_icon"] forState:UIControlStateNormal];
            break;
        case MusicCycleTypeLoopSingle:
            [_musicCycleButton setImage:[UIImage imageNamed:@"loop_single_icon"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

- (void)setupRadioMusicIfNeeded {
    _musicMenuButton.hidden = NO;
    [self updateMusicCycleButton];
    [self checkCurrentIndex];
}

- (void)checkMusicFavoritedIcon {
    if ([self hasBeenFavoriteMusic]) {
        [_favoriteButton setImage:[UIImage imageNamed:@"red_heart"] forState:UIControlStateNormal];
    } else {
        [_favoriteButton setImage:[UIImage imageNamed:@"empty_heart"] forState:UIControlStateNormal];
    }
}

- (void)setupBackgroudImage {
    _albumImageView.layer.cornerRadius = 7;
    _albumImageView.layer.masksToBounds = YES;
    
    NSString *imageWidth = [NSString stringWithFormat:@"%.f", (SCREEN_WIDTH - 70) * 2];
    NSURL *imageUrl = [BaseHelper qiniuImageCenter:_musicEntity.cover withWidth:imageWidth withHeight:imageWidth];
    [_backgroudImageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"music_placeholder"]];
    [_albumImageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"music_placeholder"]];
    
    if(![_visualEffectView isDescendantOfView:_backgroudView]) {
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _visualEffectView.frame = self.view.bounds;
        [_backgroudView addSubview:_visualEffectView];
        [_backgroudView addSubview:self.visualEffectView];
    }
    
    [_backgroudImageView startTransitionAnimation];
    [_albumImageView startTransitionAnimation];
}

- (void)addPanRecognizer {
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchDismissButton:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeRecognizer];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

# pragma mark - Music Action

- (IBAction)didTouchMenuButton:(id)sender {
    _dontReloadMusic = YES;
}

- (IBAction)didTouchDismissButton:(id)sender {
    __weak typeof(self) weakSelf = self;
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        weakSelf.dontReloadMusic = NO;
        weakSelf.lastMusicUrl = [weakSelf currentPlayingMusic].musicUrl.mutableCopy;
    }];
}

- (IBAction)didTouchFavoriteButton:(id)sender {
    [_favoriteButton startDuangAnimation];
    if ([self hasBeenFavoriteMusic]) {
        [self unfavoriteMusic];
    } else {
        [self favoriteMusic];
    }
}

- (IBAction)didTouchMusicCycleButton:(id)sender {
    switch (_musicCycleType) {
        case MusicCycleTypeLoopAll: {
            self.musicCycleType = MusicCycleTypeShuffle;
            [self showMiddleHint:@"随机播放"]; } break;
        case MusicCycleTypeShuffle: {
            self.musicCycleType = MusicCycleTypeLoopSingle;
            [self showMiddleHint:@"单曲循环"]; } break;
        case MusicCycleTypeLoopSingle: {
            self.musicCycleType = MusicCycleTypeLoopAll;
            [self showMiddleHint:@"列表循环"]; } break;
            
        default:
            break;
    }
    
    [GVUserDefaults standardUserDefaults].musicCycleType = self.musicCycleType;
}

- (void)setMusicIsPlaying:(BOOL)musicIsPlaying {
    _musicIsPlaying = musicIsPlaying;
    if (_musicIsPlaying) {
        [_musicToggleButton setImage:[UIImage imageNamed:@"big_pause_button"] forState:UIControlStateNormal];
    } else {
        [_musicToggleButton setImage:[UIImage imageNamed:@"big_play_button"] forState:UIControlStateNormal];
    }
}

- (IBAction)didTouchMoreButton:(id)sender {

}

# pragma mark - Musics delegate

- (void)playMusicWithSpecialIndex:(NSInteger)index {
    _currentIndex = index;
    [self createStreamer];
}

# pragma mark - Music Controls

- (IBAction)didTouchMusicToggleButton:(id)sender {
    if (_musicIsPlaying) {
        [_streamer pause];
    } else {
        [_streamer play];
    }
}

- (IBAction)didChangeMusicSliderValue:(id)sender {
    if (_streamer.status == DOUAudioStreamerFinished) {
        _streamer = nil;
        [self createStreamer];
    }
    
    [_streamer setCurrentTime:[_streamer duration] * _musicSlider.value];
    [self updateProgressLabelValue];
}

- (IBAction)playPreviousMusic:(id)sender {
    if (_musicEntities.count == 1) {
        [self showMiddleHint:@"已经是第一首歌曲"];
        return;
    }
    if (_musicCycleType == MusicCycleTypeShuffle && _musicEntities.count > 2) {
        [self setupRandomMusicIfNeed];
    } else {
        NSInteger firstIndex = 0;
        if (_currentIndex == firstIndex || [self currentIndexIsInvalid]) {
            self.currentIndex = _musicEntities.count - 1;
        } else {
            self.currentIndex--;
        }
    }
    
    [self setupStreamer];
}

- (IBAction)playNextMusic:(id)sender {
    if (_musicEntities.count == 1) {
        [self showMiddleHint:@"已经是最后一首歌曲"];
        return;
    }
    if (_musicCycleType == MusicCycleTypeShuffle && _musicEntities.count > 2) {
        [self setupRandomMusicIfNeed];
    } else {
        [self checkNextIndexValue];
    }
    
    [self setupStreamer];
}

- (void)checkNextIndexValue {
    NSInteger lastIndex = _musicEntities.count - 1;
    if (_currentIndex == lastIndex || [self currentIndexIsInvalid]) {
        self.currentIndex = 0;
    } else {
        self.currentIndex++;
    }
}

# pragma mark - Setup streamer

- (void)setupRandomMusicIfNeed {
    [self loadOriginArrayIfNeeded];
    int t = arc4random()%_originArray.count;
    _randomArray[0] = _originArray[t];
    _originArray[t] = _originArray.lastObject;
    [_originArray removeLastObject];
    self.currentIndex = [_randomArray[0] integerValue];
}

- (void)setupStreamer {
    [self createStreamer];
}

# pragma mark - Check Current Index

- (BOOL)currentIndexIsInvalid {
    return _currentIndex >= _musicEntities.count;
}

- (void)checkCurrentIndex {
    if ([self currentIndexIsInvalid]) {
        _currentIndex = 0;
    }
}

# pragma mark - Handle Music Slider

- (void)updateSliderValue:(id)timer {
    if (!_streamer) {
        return;
    }
    if (_streamer.status == DOUAudioStreamerFinished) {
        [_streamer play];
    }
    
    if ([_streamer duration] == 0.0) {
        [_musicSlider setValue:0.0f animated:NO];
    } else {
        if (_streamer.currentTime >= _streamer.duration) {
            _streamer.currentTime -= _streamer.duration;
        }
        
        [_musicSlider setValue:[_streamer currentTime] / [_streamer duration] animated:YES];
        [self updateProgressLabelValue];
    }
    
}

- (void)updateProgressLabelValue {
    _beginTimeLabel.text = [NSString timeIntervalToMMSSFormat:_streamer.currentTime];
    _endTimeLabel.text = [NSString timeIntervalToMMSSFormat:_streamer.duration];
}

- (void)updateBufferingStatus {
    
}

- (void)invalidMusicDurationTimer {
    if ([_musicDurationTimer isValid]) {
        [_musicDurationTimer invalidate];
    }
    _musicDurationTimer = nil;
}

# pragma mark - Audio Handle

- (void)createStreamer {
    if (_specialIndex > 0) {
        _currentIndex = _specialIndex;
        _specialIndex = 0;
    }
    
    [self setupMusicViewWithMusicEntity:_musicEntities[_currentIndex]];
    [self loadPreviousAndNextMusicImage];
    [MusicHandler configNowPlayingInfoCenter];
    
    Track *track = [[Track alloc] init];
    
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:_musicEntity.fileName ofType: @"mp3"];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
    
//    track.audioFileURL = [NSURL URLWithString:_musicEntity.musicUrl];
    track.audioFileURL = fileURL;
    
    @try {
        [self removeStreamerObserver];
    } @catch(id anException){
    }
    
    _streamer = nil;
    _streamer = [DOUAudioStreamer streamerWithAudioFile:track];
    
    [self addStreamerObserver];
    [self.streamer play];
}

- (void)removeStreamerObserver {
    [_streamer removeObserver:self forKeyPath:@"status"];
    [_streamer removeObserver:self forKeyPath:@"duration"];
    [_streamer removeObserver:self forKeyPath:@"bufferingRatio"];
}

- (void)addStreamerObserver {
    [_streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
    [_streamer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:kDurationKVOKey];
    [_streamer addObserver:self forKeyPath:@"bufferingRatio" options:NSKeyValueObservingOptionNew context:kBufferingRatioKVOKey];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == kStatusKVOKey) {
        [self performSelector:@selector(updateStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    } else if (context == kDurationKVOKey) {
        [self performSelector:@selector(updateSliderValue:)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    } else if (context == kBufferingRatioKVOKey) {
        [self performSelector:@selector(updateBufferingStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)updateStatus {
    self.musicIsPlaying = NO;
    _musicIndicator.state = NAKPlaybackIndicatorViewStateStopped;
    switch ([_streamer status]) {
        case DOUAudioStreamerPlaying:
            self.musicIsPlaying = YES;
            _musicIndicator.state = NAKPlaybackIndicatorViewStatePlaying;
            break;
            
        case DOUAudioStreamerPaused:
            break;
            
        case DOUAudioStreamerIdle:
            break;
            
        case DOUAudioStreamerFinished:
            if (_musicCycleType == MusicCycleTypeLoopSingle) {
                [_streamer play];
            } else {
                [self playNextMusic:nil];
            }
            break;
            
        case DOUAudioStreamerBuffering:
            _musicIndicator.state = NAKPlaybackIndicatorViewStatePlaying;
            break;
            
        case DOUAudioStreamerError:
            break;
    }
    [self updateMusicsCellsState];
}

# pragma mark - Favorite Music

- (void)favoriteMusic {
    _musicEntity.isFavorited = YES;
    [_favoriteButton setImage:[UIImage imageNamed:@"red_heart"] forState:UIControlStateNormal];
}

- (void)unfavoriteMusic {
    _musicEntity.isFavorited = NO;
    [_favoriteButton setImage:[UIImage imageNamed:@"empty_heart"] forState:UIControlStateNormal];
}

- (BOOL)hasBeenFavoriteMusic {
    return _musicEntity.isFavorited;
}

# pragma mark - Musics Delegate

- (void)updateMusicsCellsState {
    if (_delegate && [_delegate respondsToSelector:@selector(updatePlaybackIndicatorOfVisisbleCells)]) {
        [_delegate updatePlaybackIndicatorOfVisisbleCells];
    }
}

# pragma mark - Music convenient method

- (void)loadPreviousAndNextMusicImage {
    [MusicHandler cacheMusicCoverWithMusicEntities:_musicEntities currentIndex:_currentIndex];
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

# pragma mark - Public Method

- (MusicEntity *)currentPlayingMusic {
    if (_musicEntities.count == 0) {
        _musicEntities = nil;
    }
    
    return _musicEntities[_currentIndex];
}

@end
