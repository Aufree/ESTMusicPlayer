//
//  MusicListCell.m
//  Enesco
//
//  Created by Aufree on 11/30/15.
//  Copyright © 2015 The EST Group. All rights reserved.
//

#import "MusicListCell.h"

@interface MusicListCell ()
@property (weak, nonatomic) IBOutlet UILabel *musicNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *musicTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *musicArtistLabel;
@property (weak, nonatomic) IBOutlet NAKPlaybackIndicatorView *musicIndicator;
@end

@implementation MusicListCell

- (void)setMusicNumber:(NSInteger)musicNumber {
    _musicNumber = musicNumber;
    _musicNumberLabel.text = [NSString stringWithFormat:@"%ld", (long)musicNumber];
    if (musicNumber > 999) {
        _musicNumberLabel.font = [UIFont systemFontOfSize:13];
    }
}

- (void)setMusicEntity:(MusicEntity *)musicEntity {
    _musicEntity = musicEntity;
    _musicTitleLabel.text = _musicEntity.name;
    _musicArtistLabel.text = _musicEntity.artistName;
}

- (NAKPlaybackIndicatorViewState)state {
    return self.musicIndicator.state;
}

- (void)setState:(NAKPlaybackIndicatorViewState)state {
    self.musicIndicator.state = state;
    self.musicNumberLabel.hidden = (state != NAKPlaybackIndicatorViewStateStopped);
}

@end
