//
//  EntityProtocol.h
//  Gosu
//
//  Created by dragon on 4/17/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@protocol EntityProtocol <NSObject>


/**
 Create a object from the Parse Object in the context, but don't save.
 */
+ (instancetype) objectFromParseObject:(PFObject *)object inContext:(NSManagedObjectContext *)context;

- (void)fillInFromParseObject:(PFObject *)object;
@end
