//
//  MusicListEntity.h
//  Ting
//
//  Created by Aufree on 11/13/15.
//  Copyright © 2015 Ting. All rights reserved.
//

#import "BaseEntity.h"

@interface MusicListEntity : BaseEntity
@property (nonatomic, copy) NSNumber *musicListId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *musicDescription;
@property (nonatomic, copy) NSString *cover;
@property (nonatomic, copy) NSNumber *userId;
@property (nonatomic, copy) NSNumber *musicCount;
@property (nonatomic, copy) NSNumber *musicLength;
@property (nonatomic, copy) NSNumber *boxCurrentUsedCount;
@property (nonatomic, copy) NSNumber *favoriteCount;
@property (nonatomic, copy) NSNumber *commentCount;
@property (nonatomic, strong) NSDate *createdAtDate;
@property (nonatomic, strong) NSDate *updatedAtDate;
@end
