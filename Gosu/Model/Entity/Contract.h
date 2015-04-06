//
//  Contract.h
//  Gosu
//
//  Created by dragon on 5/22/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Review, Task, User;

@interface Contract : NSManagedObject

@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSNumber * role;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) User *employee;
@property (nonatomic, retain) User *observer;
@property (nonatomic, retain) Review *review;
@property (nonatomic, retain) Task *task;

@end
