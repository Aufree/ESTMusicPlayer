//
//  MusicHandler.h
//  Ting
//
//  Created by Aufree on 11/23/15.
//  Copyright © 2015 Ting. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicHandler : NSObject
+ (void)cacheMusicCoverWithMusicEntities:(NSArray *)musicEntities currentIndex:(NSInteger)currentIndex;
+ (void)configNowPlayingInfoCenter;
@end
