//
//  GVUserDefaults+Properties.h
//  Ting
//
//  Created by Aufree on 9/30/15.
//  Copyright (c) 2015 The EST Group. All rights reserved.
//

#import "GVUserDefaults.h"

typedef NS_ENUM(NSInteger, MusicCycleType) {
    MusicCycleTypeLoopAll = 0,
    MusicCycleTypeLoopSingle = 1,
    MusicCycleTypeShuffle = 2,
};

@interface GVUserDefaults (Properties)
@property (nonatomic, copy) NSString *userLoginToken;
@property (nonatomic, copy) NSString *userClientToken;
@property (nonatomic, copy) NSNumber *currentUserId;
@property (nonatomic, strong) NSDate *lastTimeShowLaunchScreenAd;
@property (nonatomic, assign) MusicCycleType musicCycleType;
@property (nonatomic, assign) BOOL shouldShowNotWiFiAlertView;
@end
