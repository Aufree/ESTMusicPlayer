//
//  BaseHelper.m
//  Ting
//
//  Created by Aufree on 9/22/15.
//  Copyright (c) 2015 The EST Group. All rights reserved.
//

#import "BaseHelper.h"

@implementation BaseHelper

// Center Square Image
+ (NSURL *)qiniuImageCenter:(NSString *)link
                 withWidth:(NSString *)width
                withHeight:(NSString *)height
{
    
    NSString *url = [[NSString alloc] init];
    if([height isEqualToString:@"0"]) {
        url = [NSString stringWithFormat:@"%@?imageView2/2/w/%@/", link, width];
    } else {
        url = [NSString stringWithFormat:@"%@?imageView/1/w/%@/h/%@", link, width, height];
    }
    return [NSURL URLWithString:url];
}

+ (NSURL *)qiniuImageCenter:(NSString *)link
                 withWidth:(NSString *)width
                withHeight:(NSString *)height
                      mode:(NSInteger)model
{
    NSString *url = [[NSString alloc] init];
    url = [NSString stringWithFormat:@"%@?imageView/%ld/w/%@/h/%@", link, (long)model, width, height];
    return [NSURL URLWithString:url];
}

@end
