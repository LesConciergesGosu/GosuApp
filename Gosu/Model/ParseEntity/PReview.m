//
//  PReview.m
//  Gosu
//
//  Created by dragon on 3/28/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "PReview.h"
#import <Parse/PFObject+Subclass.h>

NSString *const kParseReviewClassKey  = @"Review";
NSString *const kParseReviewTaskKey = @"task";
NSString *const kParseReviewContractKey = @"contract";
NSString *const kParseReviewFromUserKey = @"fromUser";
NSString *const kParseReviewToUserKey = @"toUser";
NSString *const kParseReviewRatingKey = @"rating";
NSString *const kParseReviewGosuKey = @"gosu";

@implementation PReview
@dynamic task;
@dynamic contract;
@dynamic fromUser;
@dynamic toUser;
@dynamic rating;
@dynamic gosu;

+ (NSString *)parseClassName {
    return kParseReviewClassKey;
}

@end
