//
//  AccessTokenHandler.h
//  Ting
//
//  Created by Aufree on 9/21/15.
//  Copyright (c) 2015 Aufree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseApi.h"

@interface AccessTokenHandler : NSObject

+ (void)fetchClientGrantToken;

+ (NSString *)getClientGrantAccessTokenFromLocal;
+ (NSString *)getLoginTokenGrantAccessToken;

+ (void)storeClientGrantAccessToken:(NSString *)token;
+ (void)storeLoginTokenGrantAccessToken:(NSString *)token;

+ (void)clearToken;

+ (void)fetchClientGrantTokenWithRetryTimes:(NSInteger)times callback:(BaseResultBlock)block;
@end
