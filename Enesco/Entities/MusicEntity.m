//
//  MusicEntity.m
//  Ting
//
//  Created by Aufree on 11/13/15.
//  Copyright © 2015 Ting. All rights reserved.
//

#import "MusicEntity.h"

@implementation MusicEntity

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"musicId" : @"id",
             @"sId" : @"s_id",
             @"name" : @"title",
             @"cover" : @"pic",
             @"artistName" : @"artist",
             };
}

@end
