//
//  PNotification.m
//  Gosu
//
//  Created by dragon on 6/14/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "PNotification.h"
#import <Parse/PFObject+Subclass.h>

NSString *const kParseNotificationClassKey = @"Notification";
@implementation PNotification
@dynamic message;
@dynamic status;
@dynamic type;
@dynamic task;
@dynamic to;
@dynamic from;

+ (NSString *)parseClassName {
    return kParseNotificationClassKey;
}

@end
