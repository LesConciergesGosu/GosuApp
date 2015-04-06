//
//  Contract+Extra.m
//  Gosu
//
//  Created by dragon on 3/31/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "Contract+Extra.h"
#import "User+Extra.h"
#import "Task+Extra.h"
#import "Review+Extra.h"

#import "PContract.h"
#import "PTask.h"
#import "DataManager.h"


@implementation Contract (Extra)

+ (instancetype) objectFromParseObject:(PFObject *)object inContext:(NSManagedObjectContext *)context {
    
    if (!object)
        return nil;
    
    PContract *pContract = (PContract *)object;
    Contract *res = [[DataManager manager] managedObjectWithID:pContract.objectId
                                                withEntityName:@"Contract"
                                                     inContext:context];
    
    
    
    return res;
}



- (void) fillInFromParseObject:(PContract *)pContract
{
    if ([pContract isDataAvailable]) {
        
        if ([pContract.updatedAt isEqualToDate:self.updatedAt])
            return;
        
        self.updatedAt = pContract.updatedAt;
        
        NSManagedObjectContext *context = self.managedObjectContext;
        
        self.task = [[DataManager manager] managedObjectWithID:[pContract task].objectId
                                               withEntityName:@"Task"
                                                    inContext:context];
        
        if (pContract.employee)
            self.employee = [User objectFromParseObject:[pContract employee] inContext:context];
        
        if (pContract.review)
            self.review = [Review objectFromParseObject:[pContract review] inContext:context];
        
        if (pContract.observer)
            self.observer = [User objectFromParseObject:[pContract observer] inContext:context];
        
        self.status = @(pContract.status);
        self.role = @(pContract.role);
    }
}

- (User *) owner {
    return [self task].customer;
}

@end
