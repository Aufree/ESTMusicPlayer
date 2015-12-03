//
//  NSString+Additions.h
//  Ting
//
//  Created by Aufree on 10/1/15.
//  Copyright © 2015 The EST Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)
+ (BOOL)isStringEmpty:(NSString *)string;
+ (NSNumber *)covertToNumber:(NSString *)numberString;
+ (NSString *)timestampString;
+ (NSString *)stringWithMD5OfFile:(NSString *) path;
- (NSString *)md5Hash;
+ (NSString *)randomStringWithLength:(int)len;
+ (NSString *)timeIntervalToMMSSFormat:(NSTimeInterval)interval;
@end
