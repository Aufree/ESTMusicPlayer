//
//  BaseApi.m
//  Ting
//
//  Created by Aufree on 9/21/15.
//  Copyright (c) 2015 The EST Group. All rights reserved.
//

#import "BaseApi.h"
#import "AccessTokenHandler.h"

@implementation BaseApi
#pragma mark - Share Instance

+ (instancetype)loginTokenGrantInstance {
    static BaseApi *_loginGrantInstance = nil;
    static dispatch_once_t loginGrantOnceToken;
    dispatch_once(&loginGrantOnceToken, ^{
        _loginGrantInstance = [[BaseApi alloc] initWithBaseURL:[NSURL URLWithString:APIBaseURL]];
        
        [_loginGrantInstance prepareForCommonRequest];
        [_loginGrantInstance setUpLoginTokenGrantRequest];
    });
    return _loginGrantInstance;
}

+ (instancetype)clientGrantInstance {
    static BaseApi *_clientGrantInstance = nil;
    static dispatch_once_t clientGrantOnceToken;
    dispatch_once(&clientGrantOnceToken, ^{
        _clientGrantInstance = [[BaseApi alloc] initWithBaseURL:[NSURL URLWithString:APIBaseURL]];
        
        [_clientGrantInstance prepareForCommonRequest];
        [_clientGrantInstance setUpClientGrantRequest];
    });
    return _clientGrantInstance;
}

#pragma mark - Helper

- (void)prepareForCommonRequest {
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString *buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    [self.requestSerializer setValue:@"application/vnd.Ting.v1+json" forHTTPHeaderField:@"Accept"];
    [self.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"X-Client-Platform"];
    [self.requestSerializer setValue:version forHTTPHeaderField:@"X-Client-Version"];
    [self.requestSerializer setValue:buildNumber forHTTPHeaderField:@"X-Client-Build"];
    [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Cookie"];
    self.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    
    self.handler = [[APIRequestHandler alloc] init];
}

- (void)setUpLoginTokenGrantRequest {
    [self.requestSerializer setValue:[AccessTokenHandler getLoginTokenGrantAccessToken]
                  forHTTPHeaderField:@"Authorization"];
    self.handler.grantType = @"owner_token";
}

- (void)setUpClientGrantRequest {
    [self.requestSerializer setValue:[AccessTokenHandler getClientGrantAccessTokenFromLocal]
                  forHTTPHeaderField:@"Authorization"];
    self.handler.grantType = @"client_credentials";
}

#pragma mark - Abstract Method

- (id)create:(id)entity withBlock:(BaseResultBlock)block {
    NSLog(@"You must override %@ in a subclass",NSStringFromSelector(_cmd));
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)update:(id)entity withBlock:(BaseResultBlock)block {
    NSLog(@"You must override %@ in a subclass",NSStringFromSelector(_cmd));
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)upvote:(id)entity withBlock:(BaseResultBlock)block {
    NSLog(@"You must override %@ in a subclass",NSStringFromSelector(_cmd));
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

// over ride AFHTTPSessionManager to fix the laravel dont support PUT problem.

- (NSURLSessionDataTask *)PUT:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSMutableDictionary *ext_parameters = [parameters mutableCopy];
    
    // add PUT
    [ext_parameters setObject:@"PUT" forKey:@"_method"];
    
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:ext_parameters error:nil];
    
    __block NSURLSessionDataTask *task = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        if (error) {
            if (failure) {
                failure(task, error);
            }
        } else {
            if (success) {
                success(task, responseObject);
            }
        }
    }];
    
    [task resume];
    
    return task;
}

// over ride AFHTTPSessionManager to fix the laravel dont support DELETE problem.

- (NSURLSessionDataTask *)DELETE:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
                         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                         failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
    NSMutableDictionary *ext_parameters = [parameters mutableCopy];
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"DELETE" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:ext_parameters error:nil];
    
    __block NSURLSessionDataTask *task = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        if (error) {
            if (failure) {
                failure(task, error);
            }
        } else {
            if (success) {
                success(task, responseObject);
            }
        }
    }];
    
    [task resume];
    
    return task;
}

@end