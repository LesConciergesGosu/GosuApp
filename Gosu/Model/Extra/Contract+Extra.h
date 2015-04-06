//
//  Contract+Extra.h
//  Gosu
//
//  Created by dragon on 3/31/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "Contract.h"
#import "EntityProtocol.h"

@class User;
@class PContract;
@interface Contract (Extra)<EntityProtocol>


/**
 customer of the task where the contract open.
 */
- (User *)owner;
@end
