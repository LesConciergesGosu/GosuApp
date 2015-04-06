//
//  GosuRelation+Extra.m
//  Gosu
//
//  Created by dragon on 6/14/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "GosuRelation+Extra.h"
#import "User+Extra.h"
#import "PGosu.h"
#import "DataManager.h"

@implementation GosuRelation (Extra)

+ (instancetype) objectFromParseObject:(PFObject *)object inContext:(NSManagedObjectContext *)context
{
    if (!object)
        return nil;
    
    PGosu *pRelation = (PGosu *)object;
    GosuRelation *relation = [[DataManager manager] managedObjectWithID:[pRelation objectId]
                                             withEntityName:@"GosuRelation"
                                                  inContext:context];
    
    
    [relation fillInFromParseObject:pRelation];
    
    return relation;
}

- (void) fillInFromParseObject:(PGosu *)pRelation {
    
    if ([pRelation isDataAvailable]) {
        
        NSManagedObjectContext *context = self.managedObjectContext;
        
        if ([pRelation.updatedAt isEqualToDate:self.updatedAt])
            return;
        
        User *from = [User objectFromParseObject:pRelation.from inContext:context];
        if (from != self.from)
            self.from = from;
        
        User *to = [User objectFromParseObject:pRelation.to inContext:context];
        if (to != self.to)
            self.to = to;
        
        self.updatedAt = pRelation.updatedAt;
    }
}

@end
