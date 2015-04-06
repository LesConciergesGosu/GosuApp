//
//  NSError+Extra.h
//  Gosu
//
//  Created by dragon on 3/30/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const GosuErrorDomain;

@interface NSError (Extra)

+ (NSError *)appErrorWithMessage:(NSString *)message;

- (NSString *)displayString;
- (BOOL)isAppError;

@end
