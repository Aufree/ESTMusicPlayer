//
//  MusicListEntity.m
//  Ting
//
//  Created by Aufree on 11/13/15.
//  Copyright © 2015 Ting. All rights reserved.
//

#import "MusicListEntity.h"

@implementation MusicListEntity

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"musicListId" : @"id",
             @"name" : @"name",
             @"musicDescription" : @"description",
             @"cover" : @"cover",
             @"musicCount" : @"music_count",
             @"musicLength" : @"music_length",
             @"favoriteCount" : @"favorite_count",
             @"commentCount" : @"comment_count",
             @"boxCurrentUsedCount" : @"box_current_used_count",
             @"userId" : @"user_id",
             @"createdAtDate" : @"created_at",
             @"updatedAtDate" : @"updated_at",
             };
}

@end
