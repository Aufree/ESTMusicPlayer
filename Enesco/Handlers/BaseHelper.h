//
//  BaseHelper.h
//  Ting
//
//  Created by Aufree on 9/22/15.
//  Copyright (c) 2015 The EST Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseHelper : NSObject

+ (NSURL *)qiniuImageCenter:(NSString *)link
                 withWidth:(NSString *)width
                withHeight:(NSString *)height;

+ (NSURL *)qiniuImageCenter:(NSString *)link
                 withWidth:(NSString *)width
                withHeight:(NSString *)height
                      mode:(NSInteger)model;

@end
