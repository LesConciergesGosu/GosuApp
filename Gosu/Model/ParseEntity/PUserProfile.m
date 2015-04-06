//
//  PUserProfile.m
//  Gosu
//
//  Created by dragon on 5/22/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "PUserProfile.h"
#import <Parse/PFObject+Subclass.h>

@implementation PUserProfile
@dynamic family;
@dynamic favorites;
@dynamic general;
@dynamic owner;
@dynamic countOfCompletedTasks;
@dynamic countOfOngoingTasks;
@dynamic savedHours;

+ (NSString *)parseClassName {
    return @"UserProfile";
}

@end
