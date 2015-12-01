//
//  MusicApi.m
//  Ting
//
//  Created by Aufree on 11/13/15.
//  Copyright © 2015 Ting. All rights reserved.
//

#import "MusicApi.h"

@implementation MusicApi

# pragma mark Music

- (id)getAllMusicsWithCallback:(BaseResultBlock)callback {    
    NSString *urlPath = @"http://tinger.herokuapp.com/api/songs";
    
    BaseRequestSuccessBlock successBlock = ^(NSURLSessionDataTask * __unused task, id rawData) {
        NSArray *data = [MusicEntity arrayOfEntitiesFromArray:(NSArray *)rawData];
        if (callback) callback(data, nil);
    };
    
    BaseRequestFailureBlock failureBlock = ^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (callback) callback(nil, error);
    };
    
    return [[BaseApi clientGrantInstance] GET:urlPath parameters:nil success:successBlock failure:failureBlock];
}

- (id)getMusicUrlWithSid:(NSNumber *)sid callback:(BaseResultBlock)callback {
    
    NSString *urlPath = [NSString stringWithFormat:@"http://inmusic.sinaapp.com/xiami_api/%@", sid];
    
    BaseRequestSuccessBlock successBlock = ^(NSURLSessionDataTask * __unused task, id rawData) {
        if (callback) callback(rawData[@"songurl"], nil);
    };
    
    BaseRequestFailureBlock failureBlock = ^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (callback) callback(nil, error);
    };
    
    return [[BaseApi clientGrantInstance] GET:urlPath parameters:nil success:successBlock failure:failureBlock];
}

@end