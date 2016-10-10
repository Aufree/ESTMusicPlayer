//
//  MusicHandler.m
//  Ting
//
//  Created by Aufree on 11/23/15.
//  Copyright © 2015 Ting. All rights reserved.
//

#import "MusicHandler.h"
#import "MusicEntity.h"
#import "MusicViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation MusicHandler

+ (void)cacheMusicCoverWithMusicEntities:(NSArray *)musicEntities currentIndex:(NSInteger)currentIndex {
    NSInteger previoudsIndex = currentIndex-1;
    NSInteger nextIndex = currentIndex+1;
    previoudsIndex = previoudsIndex < 0 ? 0 : previoudsIndex;
    nextIndex = nextIndex == musicEntities.count ? musicEntities.count - 1 : nextIndex;
    NSMutableArray *indexArray = @[].mutableCopy;
    [indexArray addObject:[NSNumber numberWithInteger:previoudsIndex]];
    [indexArray addObject:[NSNumber numberWithInteger:nextIndex]];
    for (NSNumber *indexNum in indexArray) {
        NSString *imageWidth = [NSString stringWithFormat:@"%.f", (SCREEN_WIDTH - 70) * 2];
        MusicEntity *music = musicEntities[indexNum.integerValue];
        NSURL *imageUrl = [BaseHelper qiniuImageCenter:music.cover withWidth:imageWidth withHeight:imageWidth];
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageUrl.absoluteString];
        if (!image) {
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:imageUrl options:SDWebImageDownloaderUseNSURLCache progress:nil completed:nil];
        }
    }
}

+ (void)configNowPlayingInfoCenter {
    if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        MusicEntity *music = [MusicViewController sharedInstance].currentPlayingMusic;
        
        AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:music.musicUrl] options:nil];
        CMTime audioDuration = audioAsset.duration;
        float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
        
        [dict setObject:music.name forKey:MPMediaItemPropertyTitle];
        [dict setObject:music.artistName forKey:MPMediaItemPropertyArtist];
        [dict setObject:[MusicViewController sharedInstance].musicTitle forKey:MPMediaItemPropertyAlbumTitle];
        [dict setObject:@(audioDurationSeconds) forKey:MPMediaItemPropertyPlaybackDuration];
        CGFloat playerAlbumWidth = (SCREEN_WIDTH - 16) * 2;
        UIImageView *playerAlbum = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, playerAlbumWidth, playerAlbumWidth)];
        UIImage *placeholderImage = [UIImage imageNamed:@"music_lock_screen_placeholder"];
        NSURL *URL = [BaseHelper qiniuImageCenter:music.cover
                                        withWidth:[NSString stringWithFormat:@"%.f", playerAlbumWidth]
                                       withHeight:[NSString stringWithFormat:@"%.f", playerAlbumWidth]];
        [playerAlbum sd_setImageWithURL:URL
                       placeholderImage:placeholderImage
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                  if (!image) {
                                      image = [UIImage new];
                                      image = placeholderImage;
                                  }
                                  MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:image];
                                  playerAlbum.contentMode = UIViewContentModeScaleAspectFill;
                                  [dict setObject:artwork forKey:MPMediaItemPropertyArtwork];
                                  [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
                              }];
        
    }
}

@end
