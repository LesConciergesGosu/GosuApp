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
@property (strong) PFFile *voice;

@property (strong) PCreditCard *card;
@property int cardAmount;
@property int credits;
@property int hours;

@property (strong) NSArray *activeEmployees;
@property (strong) PFUser *customer;
@property TaskStatus status;

+ (NSString *)parseClassName;

- (PFUser *)mainWorker;
- (NSString *)channelName;
@end
