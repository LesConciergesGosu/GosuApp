//
//  PExperience.m
//  Gosu
//
//  Created by Dragon on 11/8/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "PExperience.h"
#import <Parse/PFObject+Subclass.h>

@implementation PExperience


@dynamic title;
@dynamic tasks;
@dynamic customer;
@dynamic status;

+ (NSString *)parseClassName {
    return @"Experience";
}

@end
