//
//  PFInstallation+Extra.h
//  Gosu
//
//  Created by dragon on 3/26/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFInstallation (Extra)

- (void) setCurrentUser:(PFUser *)user;
- (PFUser *)currentUser;

- (void) setUserType : (UserType)userType;
- (UserType) userType;
@end
