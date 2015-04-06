//
//  PFObject+Extra.m
//  Gosu
//
//  Created by dragon on 3/24/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "PFObject+Extra.h"

@implementation PFObject (Extra)

- (BOOL) isEqualTo:(PFObject *)other
{
    if ([[self objectId] isEqualToString:[other objectId]])
    {
        return YES;
    }
    
    return NO;
}

- (id) cachedObject:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[self parseClassName]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"objectId == %@", [self objectId]]];
    NSArray *res = [context executeFetchRequest:request error:nil];
    if ([res count] > 0) {
        return res[0];
    }
    
    return nil;
}

@end
