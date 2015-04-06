//
//  Notification.h
//  Gosu
//
//  Created by dragon on 6/20/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Task, User;

@interface Notification : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) User *from;
@property (nonatomic, retain) Task *task;
@property (nonatomic, retain) User *to;

@end
