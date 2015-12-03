//
//  AppDelegate.m
//  Enesco
//
//  Created by Aufree on 11/30/15.
//  Copyright © 2015 The EST Group. All rights reserved.
//

#import "AppDelegate.h"
#import "MusicListViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MusicViewController.h"

@interface AppDelegate ()
@property (nonatomic, strong) MusicListViewController *musicListVC;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Showing the App
    [self makeWindowVisible:launchOptions];
    
    // Basic setup
    [self basicSetup];
    
    return YES;
}

- (void)makeWindowVisible:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    if (!_musicListVC){
        _musicListVC = [[UIStoryboard storyboardWithName:@"MusicList" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    }
    self.window.rootViewController = _musicListVC;
    
    [self.window makeKeyAndVisible];
}


- (void)basicSetup {
    // Remove control
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

# pragma mark - Remote control

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlPause:
                [[MusicViewController sharedInstance].streamer pause];
                break;
            case UIEventSubtypeRemoteControlStop:
                break;
            case UIEventSubtypeRemoteControlPlay:
                [[MusicViewController sharedInstance].streamer play];
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [[MusicViewController sharedInstance] playNextMusic:nil];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [[MusicViewController sharedInstance] playPreviousMusic:nil];
                break;
            default:
                break;
        }
    }
}


@end
