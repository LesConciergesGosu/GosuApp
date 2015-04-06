//
//  PTask.h
//  Gosu
//
//  Created by dragon on 3/28/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Parse/Parse.h>

// Class Key
FOUNDATION_EXPORT NSString *const kParseTaskClassKey;
// Field Keys
FOUNDATION_EXPORT NSString *const kParseTaskTitleKey;
FOUNDATION_EXPORT NSString *const kParseTaskDescriptionKey;
FOUNDATION_EXPORT NSString *const kParseTaskVoiceKey;
FOUNDATION_EXPORT NSString *const kParseTaskHoursKey;
FOUNDATION_EXPORT NSString *const kParseTaskCreditsKey;
FOUNDATION_EXPORT NSString *const kParseTaskCardAmountKey;
FOUNDATION_EXPORT NSString *const kParseTaskCustomerKey;
FOUNDATION_EXPORT NSString *const kParseTaskActiveEmployeesKey;
FOUNDATION_EXPORT NSString *const kParseTaskStatusKey;

@class PCreditCard;
@interface PTask : PFObject<PFSubclassing>

@property (strong) NSString *title;
@property (strong) NSString *desc;
@property (strong) NSString *note;
@property (strong) PFFile *voice;

@property (strong) PCreditCard *card;
@property int hours;

@property (strong) NSArray *activeEmployees;
@property (strong) PFUser *customer;
@property TaskStatus status;

@property (strong) NSString *note2;
@property (strong) NSString *note3;
@property (strong) NSString *note4;
@property (strong) NSDate *date;
@property (strong) NSDate *date2;
@property (strong) PFGeoPoint *location;
@property (strong) PFGeoPoint *location2;
@property (strong) NSString *type;
@property (strong) NSString *type2;
@property (strong) NSString *type3;
@property BOOL asap;
@property int priceLevel;
@property float lowerPrice;
@property float upperPrice;
@property int numberOfPersons;
@property int numberOfAdults;
@property int numberOfChildren;
@property int numberOfInfants;
@property (strong) NSString *photoUrl;
@property (strong) NSString *offerId;
@property (strong) NSString *address;

@property (nonatomic) BOOL changed;

+ (NSString *)parseClassName;

- (PFUser *)mainWorker;
- (NSString *)channelName;
@end
