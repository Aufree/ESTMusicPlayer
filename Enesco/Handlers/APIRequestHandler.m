//
//  APIRequestHandler.m
//  Ting
//
//  Created by Aufree on 9/21/15.
//  Copyright (c) 2015 The EST Group. All rights reserved.
//

#import "APIRequestHandler.h"
#import "AccessTokenHandler.h"

@implementation APIRequestHandler

#pragma mark -  helper method

- (BOOL)isUnknowRequest:(NSURLRequest *)request {
    NSString *grantType = [self grantTypeFromRequest:request];
    return [grantType isEqualToString:@"unknow"];
}

- (BOOL)isPasswordRequest:(NSURLRequest *)request {
    NSString *grantType = [self grantTypeFromRequest:request];
    return [grantType isEqualToString:@"password"];
}

- (BOOL)isLoginRequest:(NSURLRequest *)request {
    NSString *grantType = [self grantTypeFromRequest:request];
    return [grantType isEqualToString:@"login_token"];
}

- (BOOL)isClientGrantRequest:(NSURLRequest *)request {
    NSString *grantType = [self grantTypeFromRequest:request];
    return [grantType isEqualToString:@"client_credentials"];
}

- (NSString *)grantTypeFromRequest:(NSURLRequest *)request {
    NSString *token = [request valueForHTTPHeaderField:@"Authorization"];
    
    if ([token isEqualToString:[AccessTokenHandler getClientGrantAccessTokenFromLocal]]) {
        return @"client_credentials";
    }
    
    if ([token isEqualToString:[AccessTokenHandler getLoginTokenGrantAccessToken]]) {
        return @"login_token";
    }
    
    return @"unknow";
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end