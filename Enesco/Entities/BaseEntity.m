//
//  BaseEntity.m
//  Ting
//
//  Created by Aufree on 9/21/15.
//  Copyright (c) 2015 The EST Group. All rights reserved.
//

#import "BaseEntity.h"

@implementation BaseEntity
+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSLog(@"You must override %@ in a subclass",NSStringFromSelector(_cmd));
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Common Public Methods

- (NSDictionary *)transformToDictionary {
    return [MTLJSONAdapter JSONDictionaryFromModel:self];
}

+ (NSArray *)transformToArray:(NSArray *)array
{
    return [MTLJSONAdapter JSONArrayFromModels:array];
}

+ (id)entityFromDictionary:(NSDictionary *)data
{
    NSError *error;
    id entity = [MTLJSONAdapter modelOfClass:self.class fromJSONDictionary:data error:&error];
    
    if (error) {
        NSLog(@"Couldn't convert JSON to Entity: %@", error);
        return nil;
    }
    return entity;
}

+ (NSArray *)arrayOfEntitiesFromArray:(NSArray *)array
{
    NSError *error;
    NSArray *arrayOfEntities = [MTLJSONAdapter modelsOfClass:[self class]
                                               fromJSONArray:array
                                                       error:&error];
    if (error) {
        NSLog(@"Couldn't convert app infos JSON to ChoosyAppInfo models: %@", error);
        return nil;
    }
    return arrayOfEntities;
}

#pragma mark - Share Property convertor

+ (NSValueTransformer *)createdAtJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [self.dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

+ (NSValueTransformer *)updatedAtJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [self.dateFormatter dateFromString:str];;
    } reverseBlock:^(NSDate *date) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

#pragma mark - MTLModel Overwrite

- (NSDictionary *)dictionaryValue {
    NSMutableDictionary *modifiedDictionaryValue = [[super dictionaryValue] mutableCopy];
    
    for (NSString *originalKey in [super dictionaryValue]) {
        if ([self valueForKey:originalKey] == nil ) {
            
            if ([[self valueForKey:originalKey] isKindOfClass:[NSString class]]) {
                [modifiedDictionaryValue setObject:@"" forKey:originalKey];
            }
        }
    }
    
    return [modifiedDictionaryValue copy];
}

#pragma mark - Helpers

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *_formatter;
    
    if (!_formatter) {
        _formatter = [NSDateFormatter new];
        _formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    return _formatter;
}

@end