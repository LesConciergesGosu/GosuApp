//
//  EntityProtocol.h
//  Gosu
//
//  Created by dragon on 4/17/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EntityProtocol <NSObject>


/**
 Create a object from the Parse Object in the context, but don't save.
 */
+ (instancetype) objectFromParseObject:(id)pfObject inContext:(NSManagedObjectContext *)context;

- (void)fillInFromParseObject:(id)pfObject;
@end
