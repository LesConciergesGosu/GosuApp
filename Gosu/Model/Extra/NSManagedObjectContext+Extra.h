//
//  NSManagedObjectContext+Extra.h
//  Gosu
//
//  Created by dragon on 4/3/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Extra)

- (void)saveRecursively;
+ (NSManagedObjectContext *)contextForCurrentThread;
@end
