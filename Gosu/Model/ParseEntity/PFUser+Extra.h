//
//  PFUser+Extra.h
//  Gosu
//
//  Created by dragon on 3/23/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Parse/Parse.h>

#define GOSU_RATING 2.5

FOUNDATION_EXPORT NSString *const kParseUserTypeKey;
FOUNDATION_EXPORT NSString *const kParseUserCreditsVKey;
FOUNDATION_EXPORT NSString *const kParseUserHasProfileKey;
FOUNDATION_EXPORT NSString *const kParseUserFirstNameKey;
FOUNDATION_EXPORT NSString *const kParseUserLastNameKey;
FOUNDATION_EXPORT NSString *const kParseUserPhotoKey;
FOUNDATION_EXPORT NSString *const kParseUserRatingKey;
FOUNDATION_EXPORT NSString *const kParseUserPhoneKey;
FOUNDATION_EXPORT NSString *const kParseUserDefaultCardKey;
FOUNDATION_EXPORT NSString *const kParseUserInstallationKey;
FOUNDATION_EXPORT NSString *const kParseUserLocationKey;
FOUNDATION_EXPORT NSString *const kParseUserProfileKey;

@class PTutorial;
@class PCreditCard;
@class PUserProfile;
@interface PFUser (Extra)

- (NSString *)fullName;

- (NSString *)firstName;
- (void) setFirstName:(NSString *)firstName;

- (NSString *)lastName;
- (void) setLastName:(NSString *)lastName;

- (NSString *)phone;
- (void) setPhone:(NSString *)phone;

- (PFFile *)photo;
- (void) setPhoto:(PFFile *)photo;

- (UserType)userType;
- (void)setUserType:(UserType)type;


- (float)rating;
- (void)setRating:(float)rating;

- (PUserProfile *)profile;
- (BOOL)hasProfile;
- (void)setHasProfile:(BOOL)hasProfile;

- (int)credits;
- (void)setCredits:(int)credits;
- (void)decreaseCredits:(int)decrement;

- (PCreditCard *)defaultCreditCard;
- (void) setDefaultCreditCard:(PCreditCard *)card;

- (PFGeoPoint *) location;
- (void) setLocation:(PFGeoPoint *)location;

- (BOOL)passwordReset;
- (void)setPasswordReset:(BOOL)reset;

- (void)setCity:(NSString *)city;
- (NSString *)city;

- (void)setSandboxUser:(BOOL)sandboxUser;
- (BOOL)sandboxUser;

@end
