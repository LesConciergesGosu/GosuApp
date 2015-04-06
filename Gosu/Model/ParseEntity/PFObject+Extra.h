//
//  PFObject+Extra.h
//  Gosu
//
//  Created by dragon on 3/24/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Parse/Parse.h>
#import <CoreData/CoreData.h>

@interface PFObject (Extra)

- (BOOL) isEqualTo:(PFObject *)other;
- (id) cachedObject:(NSManagedObjectContext *)context;
@end
