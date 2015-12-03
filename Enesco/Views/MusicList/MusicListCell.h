//
//  MusicListCell.h
//  Enesco
//
//  Created by Aufree on 11/30/15.
//  Copyright © 2015 The EST Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicEntity.h"
#import "NAKPlaybackIndicatorView.h"

@protocol MusicListCellDelegate <NSObject>
@optional
- (void)jumpToMusicListVCWithCurrentIndex:(NSInteger)index;
@end

@interface MusicListCell : UITableViewCell
@property (nonatomic, assign) NSInteger musicNumber;
@property (nonatomic, strong) MusicEntity *musicEntity;
@property (nonatomic, weak) id<MusicListCellDelegate> delegate;
@property (nonatomic, assign) NAKPlaybackIndicatorViewState state;
@end
