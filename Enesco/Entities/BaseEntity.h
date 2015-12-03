//
//  BaseEntity.h
//  Ting
//
//  Created by Aufree on 9/21/15.
//  Copyright (c) 2015 The EST Group. All rights reserved.
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"
#import "MTLValueTransformer.h"
#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"

@interface BaseEntity : MTLModel <MTLJSONSerializing>
#pragma mark - Class Methods to create Entity

+ (NSDateFormatter *)dateFormatter;

+ (id)entityFromDictionary:(NSDictionary *)data;
+ (NSArray *)arrayOfEntitiesFromArray:(NSArray *)array;

#pragma mark - Instance Method

- (NSDictionary *)transformToDictionary;
+ (NSArray *)transformToArray:(NSArray *)array;
@end
