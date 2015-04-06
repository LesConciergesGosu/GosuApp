//
//  NSManagedObject+Extra.h
//  Gosu
//
//  Created by dragon on 3/31/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Extra)
+ (instancetype) object;
+ (instancetype) objectWithContext:(NSManagedObjectContext *)context;
@end
