//
//  BaseModel.h
//  Ting
//
//  Created by Aufree on 9/21/15.
//  Copyright (c) 2015 Aufree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseApi.h"

@interface BaseModel : NSObject
+ (instancetype)Instance;

- (id)create:(id)entity withBlock:(BaseResultBlock)block;
- (id)update:(id)entity withBlock:(BaseResultBlock)block;
- (id)upvote:(id)entity withBlock:(BaseResultBlock)block;
@end
