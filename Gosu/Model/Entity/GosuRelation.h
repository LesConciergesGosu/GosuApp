//
//  GosuRelation.h
//  Gosu
//
//  Created by dragon on 6/14/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface GosuRelation : NSManagedObject

@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) User *from;
@property (nonatomic, retain) User *to;

@end
