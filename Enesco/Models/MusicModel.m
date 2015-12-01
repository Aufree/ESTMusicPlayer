//
//  MusicModel.m
//  Ting
//
//  Created by Aufree on 11/13/15.
//  Copyright © 2015 Ting. All rights reserved.
//

#import "MusicModel.h"

@implementation MusicModel

# pragma mark - Initial Object

- (instancetype)init {
    self = [super init];
    if (self) {
        _api = [[MusicApi alloc] init];
    }
    return self;
}

# pragma mark - Get Music Data

- (id)getAllMusicsWithCallback:(BaseResultBlock)callback {
   return [_api getAllMusicsWithCallback:callback];
}

- (id)getMusicUrlWithSid:(NSNumber *)sid callback:(BaseResultBlock)callback {
    return [_api getMusicUrlWithSid:sid callback:callback];
}
@end
