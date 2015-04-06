//
//  Message.h
//  Gosu
//
//  Created by dragon on 6/18/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Task, User;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * draft;
@property (nonatomic, retain) NSString * file;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSNumber * photoHeight;
@property (nonatomic, retain) NSNumber * photoWidth;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * voiceDuration;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) User *author;
@property (nonatomic, retain) Task *task;

@end
