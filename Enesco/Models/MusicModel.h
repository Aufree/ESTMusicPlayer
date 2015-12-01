//
//  MusicModel.h
//  Ting
//
//  Created by Aufree on 11/13/15.
//  Copyright © 2015 Ting. All rights reserved.
//

#import "BaseModel.h"
#import "MusicApi.h"

@interface MusicModel : BaseModel
@property (nonatomic, strong) MusicApi *api;
- (id)getAllMusicsWithCallback:(BaseResultBlock)callback;
- (id)getMusicUrlWithSid:(NSNumber *)sid callback:(BaseResultBlock)callback;
@end