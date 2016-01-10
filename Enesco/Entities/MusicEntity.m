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
             @"name" : @"title",
             @"cover" : @"pic",
             @"artistName" : @"artist",
             @"musicUrl" : @"music_url",
             @"fileName" : @"file_name"
             };
}

@end
