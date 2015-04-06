//
//  PContract.h
//  Gosu
//
//  Created by dragon on 3/28/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Parse/Parse.h>

FOUNDATION_EXPORT NSString *const kParseContractClassKey;
FOUNDATION_EXPORT NSString *const kParseContractTaskKey;
FOUNDATION_EXPORT NSString *const kParseContractOwnerKey;
FOUNDATION_EXPORT NSString *const kParseContractEmployeeKey;
FOUNDATION_EXPORT NSString *const kParseContractObserverKey;
FOUNDATION_EXPORT NSString *const kParseContractReviewKey;
FOUNDATION_EXPORT NSString *const kParseContractRoleKey;
FOUNDATION_EXPORT NSString *const kParseContractStatusKey;

@class PTask;
@class PReview;
@interface PContract : PFObject<PFSubclassing>
@property (strong) PTask *task;
@property (strong) PFUser *owner;
@property (strong) PFUser *employee;
@property (strong) PFUser *observer;
@property (strong) PReview *review;
@property ContractStatus status;
@property ContractRole role;
@end
