//
//  CreditCard.h
//  Gosu
//
//  Created by dragon on 5/22/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Task, User;

@interface CreditCard : NSManagedObject

@property (nonatomic, retain) NSString * cardNumber;
@property (nonatomic, retain) NSString * ccv;
@property (nonatomic, retain) NSNumber * expiryMonth;
@property (nonatomic, retain) NSNumber * expiryYear;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * postalCode;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) User *owner;
@property (nonatomic, retain) Task *task;

@end
