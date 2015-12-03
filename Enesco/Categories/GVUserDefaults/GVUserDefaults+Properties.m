//
//  GVUserDefaults+Properties.m
//  Ting
//
//  Created by Aufree on 9/30/15.
//  Copyright (c) 2015 The EST Group. All rights reserved.
//

#import "GVUserDefaults+Properties.h"

@implementation GVUserDefaults (Properties)
@dynamic userLoginToken;
@dynamic userClientToken;
@dynamic currentUserId;
@dynamic lastTimeShowLaunchScreenAd;
@dynamic musicCycleType;
@dynamic shouldShowNotWiFiAlertView;

- (NSDictionary *)setupDefaults
{
    return @{
             @"shouldShowNotWiFiAlertView":@YES
             };
}

@end
