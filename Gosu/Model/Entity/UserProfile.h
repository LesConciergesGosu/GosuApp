//
//  UserProfile.h
//  Gosu
//
//  Created by dragon on 6/12/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface UserProfile : NSManagedObject

@property (nonatomic, retain) NSNumber * countOfCompletedTasks;
@property (nonatomic, retain) NSNumber * countOfOngoingTasks;
@property (nonatomic, retain) id family;
@property (nonatomic, retain) id favorites;
@property (nonatomic, retain) id general;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSNumber * savedHours;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * dataAvailable;
@property (nonatomic, retain) User *owner;

@end
