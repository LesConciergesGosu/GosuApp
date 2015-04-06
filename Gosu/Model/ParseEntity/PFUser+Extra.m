//
//  PFUser+Extra.m
//  Gosu
//
//  Created by dragon on 3/23/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//


#import "PFUser+Extra.h"
#import "PCreditCard.h"

NSString *const kParseUserCreditsVKey = @"credits";
NSString *const kParseUserHasProfileKey = @"hasProfile";
NSString *const kParseUserFirstNameKey = @"firstName";
NSString *const kParseUserLastNameKey = @"lastName";
NSString *const kParseUserPhotoKey = @"photo";
NSString *const kParseUserPhoneKey = @"phone";
NSString *const kParseUserRatingKey = @"rating";
NSString *const kParseUserTypeKey = @"userType";
NSString *const kParseUserDefaultCardKey = @"defaultCard";
NSString *const kParseUserInstallationKey = @"installation";
NSString *const kParseUserLocationKey = @"location";
NSString *const kParseUserProfileKey = @"profile";

@implementation PFUser (Extra)

- (NSString *)fullName
{
    if ([self isDataAvailable])
        return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    return @"";
}

- (NSString *)firstName
{
    NSString *firstName = [self objectForKey:kParseUserFirstNameKey];
    return firstName ? firstName : @"";
}

- (void) setFirstName:(NSString *)firstName
{
    [self setObject:firstName forKey:kParseUserFirstNameKey];
}

- (NSString *)lastName
{
    NSString *lastName = [self objectForKey:kParseUserLastNameKey];
    return lastName ? lastName : @"";
}

- (void) setLastName:(NSString *)lastName
{
    [self setObject:lastName forKey:kParseUserLastNameKey];
}

- (NSString *)phone
{
    return [self objectForKey:kParseUserPhoneKey];
}

- (void) setPhone:(NSString *)phone
{
    [self setObject:phone forKey:kParseUserPhoneKey];
}

- (PFFile *)photo
{
    return [self objectForKey:kParseUserPhotoKey];
}

- (void) setPhoto:(PFFile *)photo
{
    [self setObject:photo forKey:kParseUserPhotoKey];
}


- (UserType)userType
{
    return [[self objectForKey:kParseUserTypeKey] intValue];
}

- (void)setUserType:(UserType)type
{
    [self setObject:@(type) forKey:kParseUserTypeKey];
}

- (float)rating
{
    return [[self objectForKey:kParseUserRatingKey] floatValue];
}

- (void)setRating:(float)rating
{
    [self setObject:@(rating) forKey:kParseUserRatingKey];
}

- (PUserProfile *)profile
{
    return [self objectForKey:kParseUserProfileKey];
}

- (BOOL) hasProfile
{
    return [[self objectForKey:kParseUserHasProfileKey] boolValue];
}

- (void)setHasProfile:(BOOL)hasProfile
{
    [self setObject:@(hasProfile) forKey:kParseUserHasProfileKey];
}

- (int)credits
{
    return [[self objectForKey:kParseUserCreditsVKey] intValue];
}

- (void)setCredits:(int)credits
{
    [self setObject:@(credits) forKey:kParseUserCreditsVKey];
}

- (void)decreaseCredits:(int)decrement
{
    int credits = self.credits;
    credits = credits >= decrement ? credits - decrement : 0;
    self.credits = credits;
}

- (PCreditCard *)defaultCreditCard {
    return [self objectForKey:kParseUserDefaultCardKey];
}
- (void) setDefaultCreditCard:(PCreditCard *)pCard {
    [self setObject:pCard forKey:kParseUserDefaultCardKey];
}

- (PFGeoPoint *) location {
    return self[kParseUserLocationKey];
}

- (void) setLocation:(PFGeoPoint *)location {
    self[kParseUserLocationKey] = location;
}

- (BOOL)passwordReset {
    return [self[@"passwordReset"] boolValue];
}

- (void)setPasswordReset:(BOOL)reset {
    [self setObject:@(reset) forKey:@"passwordReset"];
}


@end
