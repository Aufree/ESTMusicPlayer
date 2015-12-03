//
//  MusicListViewController.h
//  Enesco
//
//  Created by Aufree on 11/30/15.
//  Copyright © 2015 The EST Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MusicListViewControllerDelegate <NSObject>
- (void)playMusicWithSpecialIndex:(NSInteger)index;
@end

@interface MusicListViewController : UITableViewController
@property (nonatomic, weak) id <MusicListViewControllerDelegate> delegate;
@end
