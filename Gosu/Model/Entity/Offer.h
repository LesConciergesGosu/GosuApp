//
//  Offer.h
//  Gosu
//
//  Created by Dragon on 10/15/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Offer : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * approachOrSophistic;
@property (nonatomic, retain) NSNumber * archived;
@property (nonatomic, retain) NSString * benefit;
@property (nonatomic, retain) NSNumber * category;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * destination;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * endTime;
@property (nonatomic, retain) NSNumber * energeticOrQuiet;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * limitedOrFull;
@property (nonatomic, retain) NSNumber * localTimeZone;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * offer;
@property (nonatomic, retain) id offeredTo;
@property (nonatomic, retain) id offerOptions;
@property (nonatomic, retain) NSString * photoUrl;
@property (nonatomic, retain) id price;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSNumber * romanticOrFamily;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSNumber * startTime;
@property (nonatomic, retain) NSString * subCat;
@property (nonatomic, retain) NSNumber * tradOrModern;
@property (nonatomic, retain) NSNumber * urbanOrAdventure;
@property (nonatomic, retain) NSNumber * zipCode;
@property (nonatomic, retain) User *user;

@end
