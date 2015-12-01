//
//  BaseModel.m
//  Ting
//
//  Created by Aufree on 9/21/15.
//  Copyright (c) 2015 Aufree. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel
+ (instancetype)Instance
{
    return [[self alloc] init];
}

- (id)create:(id)entity withBlock:(BaseResultBlock)block
{
    NSLog(@"You must override %@ in a subclass",NSStringFromSelector(_cmd));
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)update:(id)entity withBlock:(BaseResultBlock)block
{
    NSLog(@"You must override %@ in a subclass",NSStringFromSelector(_cmd));
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)upvote:(id)entity withBlock:(BaseResultBlock)block
{
    NSLog(@"You must override %@ in a subclass",NSStringFromSelector(_cmd));
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
@end
