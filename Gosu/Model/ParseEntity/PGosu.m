//
//  PGosu.m
//  Gosu
//
//  Created by dragon on 4/18/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "PGosu.h"
#import <Parse/PFObject+Subclass.h>

NSString *const kParseGosuClassKey = @"Gosu";

@implementation PGosu
@dynamic from;
@dynamic to;
@dynamic review;

+ (NSString *)parseClassName {
    return kParseGosuClassKey;
}

@end
