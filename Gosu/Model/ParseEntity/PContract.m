//
//  PContract.m
//  Gosu
//
//  Created by dragon on 3/28/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "PContract.h"
#import <Parse/PFObject+Subclass.h>

NSString *const kParseContractClassKey = @"Contract";
NSString *const kParseContractTaskKey = @"task";
NSString *const kParseContractOwnerKey = @"owner";
NSString *const kParseContractEmployeeKey = @"employee";
NSString *const kParseContractObserverKey = @"observer";
NSString *const kParseContractReviewKey = @"review";
NSString *const kParseContractRoleKey = @"role";
NSString *const kParseContractStatusKey = @"status";

@implementation PContract
@dynamic task;
@dynamic owner;
@dynamic employee;
@dynamic observer;
@dynamic review;
@dynamic status;
@dynamic role;

+ (NSString *)parseClassName {
    return kParseContractClassKey;
}

@end
