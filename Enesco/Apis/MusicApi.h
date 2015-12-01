//
//  MusicApi.h
//  Ting
//
//  Created by Aufree on 11/13/15.
//  Copyright © 2015 Ting. All rights reserved.
//

#import "BaseApi.h"
#import "MusicListEntity.h"
#import "MusicEntity.h"

@interface MusicApi : BaseApi
- (id)getAllMusicsWithCallback:(BaseResultBlock)callback;
- (id)getMusicUrlWithSid:(NSNumber *)sid callback:(BaseResultBlock)callback;
@end
