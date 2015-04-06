//
//  Review+Extra.m
//  Gosu
//
//  Created by dragon on 3/31/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "Review+Extra.h"
#import "User+Extra.h"
#import "PContract.h"
#import "PFUser+Extra.h"
#import "PReview.h"
#import "PTask.h"
#import "DataManager.h"

@implementation Review (Extra)

+ (instancetype) objectFromParseObject:(PFObject *)object inContext:(NSManagedObjectContext *)context {
    
    if (!object)
        return nil;
    
    PReview *pReview = (PReview *)object;
    Review *res = [[DataManager manager] managedObjectWithID:pReview.objectId withEntityName:@"Review" inContext:context];
    
    [res fillInFromParseObject:pReview];
    
    return res;
}

- (void) fillInFromParseObject:(PReview *)pReview {
    
    if ([pReview isDataAvailable]) {
        
        if (pReview.rating != [self.rating floatValue])
            self.rating = @(pReview.rating);
        
        if (pReview.gosu != [self.gosu boolValue])
            self.gosu = @(pReview.gosu);
        
        if (!self.fromUser)
            self.fromUser = [User objectFromParseObject:pReview.fromUser inContext:self.managedObjectContext];
        
        if (!self.toUser)
            self.toUser = [User objectFromParseObject:pReview.toUser inContext:self.managedObjectContext];
        
        if (!self.contract)
            self.contract = [[DataManager manager] managedObjectWithID:pReview.contract.objectId withEntityName:@"Contract" inContext:self.managedObjectContext];
        
        if (!self.task)
            self.task = [[DataManager manager] managedObjectWithID:pReview.task.objectId withEntityName:@"Task" inContext:self.managedObjectContext];
    }
}

@end
