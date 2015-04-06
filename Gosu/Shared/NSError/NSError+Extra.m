//
//  NSError+Extra.m
//  Gosu
//
//  Created by dragon on 3/30/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "NSError+Extra.h"

NSString * const GosuErrorDomain = @"GosuErrorDomain";

@implementation NSError (Extra)


+ (NSError *)appErrorWithMessage:(NSString *)message
{
    return [NSError errorWithDomain:GosuErrorDomain
                               code:-1
                           userInfo:@{@"error":message}];
}

- (NSString *)displayString
{
    if ([self.domain isEqualToString:@"Parse"] ||
        [self.domain isEqualToString:GosuErrorDomain]) {
        return self.userInfo[@"error"];
    }
    
    return [self localizedDescription];
}

- (BOOL)isAppError
{
    return [[self domain] isEqualToString:GosuErrorDomain];
}

@end
