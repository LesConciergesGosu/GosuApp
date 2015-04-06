//
//  PReview.h
//  Gosu
//
//  Created by dragon on 3/28/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Parse/Parse.h>

FOUNDATION_EXPORT NSString *const kParseReviewClassKey;
FOUNDATION_EXPORT NSString *const kParseReviewTaskKey;
FOUNDATION_EXPORT NSString *const kParseReviewContractKey;
FOUNDATION_EXPORT NSString *const kParseReviewFromUserKey;
FOUNDATION_EXPORT NSString *const kParseReviewToUserKey;
FOUNDATION_EXPORT NSString *const kParseReviewRatingKey;
FOUNDATION_EXPORT NSString *const kParseReviewGosuKey;

@class PTask;
@class PContract;

@interface PReview : PFObject<PFSubclassing>

@property (strong) PTask *task;
@property (strong) PContract *contract;
@property (strong) PFUser *fromUser;
@property (strong) PFUser *toUser;

@property float rating;
@property BOOL gosu;

@end
