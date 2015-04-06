//
//  Review.h
//  Gosu
//
//  Created by dragon on 5/22/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contract, Task, User;

@interface Review : NSManagedObject

@property (nonatomic, retain) NSNumber * gosu;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) Contract *contract;
@property (nonatomic, retain) User *fromUser;
@property (nonatomic, retain) Task *task;
@property (nonatomic, retain) User *toUser;

@end
