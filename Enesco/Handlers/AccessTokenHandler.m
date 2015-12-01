//
//  AccessTokenHandler.m
//  Ting
//
//  Created by Aufree on 9/21/15.
//  Copyright (c) 2015 Aufree. All rights reserved.
//

#import "AccessTokenHandler.h"
#import "GVUserDefaults+Properties.h"

@implementation AccessTokenHandler
#pragma mark - Client Grant

+ (NSString *)getClientGrantAccessTokenFromLocal {
    NSString *token = [GVUserDefaults standardUserDefaults].userClientToken;
    return [NSString stringWithFormat:@"Bearer %@", token];
}

+ (void)storeClientGrantAccessToken:(NSString *)token {
    [GVUserDefaults standardUserDefaults].userClientToken = token;    
    [[BaseApi clientGrantInstance] setUpClientGrantRequest];
}

+ (void)fetchClientGrantToken {

}

+ (void)fetchClientGrantTokenWithRetryTimes:(NSInteger)times callback:(BaseResultBlock)block {

}

#pragma mark - Password Grant

+ (NSString *)getLoginTokenGrantAccessToken {
    NSString *token = [GVUserDefaults standardUserDefaults].userLoginToken;
   
    return [NSString stringWithFormat:@"Bearer %@", token];
}

+ (void)storeLoginTokenGrantAccessToken:(NSString *)token {
    [GVUserDefaults standardUserDefaults].userLoginToken = token;
    [[BaseApi loginTokenGrantInstance] setUpLoginTokenGrantRequest];
}

+ (void)clearToken {
    [GVUserDefaults standardUserDefaults].userLoginToken = nil;
    [GVUserDefaults standardUserDefaults].userClientToken = nil;
}

@end
