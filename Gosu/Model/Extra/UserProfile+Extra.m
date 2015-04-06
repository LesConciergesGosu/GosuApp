//
//  UserProfile+Extra.m
//  Gosu
//
//  Created by dragon on 5/23/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "UserProfile+Extra.h"
#import "PUserProfile.h"
#import "DataManager.h"

@implementation UserProfile (Extra)

/**
 Create a object from the Parse Object in the context, but don't save.
 */
+ (instancetype) objectFromParseObject:(PFObject *)object inContext:(NSManagedObjectContext *)context {
    
    if (!object)
        return nil;
    
    PUserProfile *pUserProfile = (PUserProfile *)object;
    UserProfile *res = [[DataManager manager] managedObjectWithID:pUserProfile.objectId withEntityName:@"UserProfile" inContext:context];
    
    [res fillInFromParseObject:pUserProfile];
    
    return res;
}

- (void)fillInFromParseObject:(PFObject *)object {
    
    PUserProfile *profile = (PUserProfile *)object;
    
    if ([profile isDataAvailable]) {
        
        if ([profile.updatedAt isEqualToDate:self.updatedAt])
            return;
        
        if (![self.dataAvailable boolValue])
            self.dataAvailable = @(YES);
        
        if ([self.countOfOngoingTasks intValue] != profile.countOfOngoingTasks)
            self.countOfOngoingTasks = @(profile.countOfOngoingTasks);
        
        if ([self.countOfCompletedTasks intValue] != profile.countOfCompletedTasks)
            self.countOfCompletedTasks = @(profile.countOfCompletedTasks);
        
        if ([self.savedHours intValue] != profile.savedHours)
            self.savedHours = @(profile.savedHours);
        
        self.general    = profile.general;
        self.family     = profile.family;
        self.favorites  = profile.favorites;
        self.updatedAt  = profile.updatedAt;
    }
}

@end
