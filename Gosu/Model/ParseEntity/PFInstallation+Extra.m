//
//  PFInstallation+Extra.m
//  Gosu
//
//  Created by dragon on 3/26/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "PFInstallation+Extra.h"

@implementation PFInstallation (Extra)

- (void) setCurrentUser:(PFUser *)user {
    [self setObject:user forKey:kParseInstallationUserKey];
}

- (PFUser *)currentUser {
    return [self objectForKey:kParseInstallationUserKey];
}

- (void) setUserType : (UserType)userType {
    [self setObject:@(userType) forKey:kParseInstallationUserTypeKey];
}

- (UserType) userType {
    return [[self objectForKey:kParseInstallationUserTypeKey] intValue];
}

@end
