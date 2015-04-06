//
//  NSManagedObject+Extra.m
//  Gosu
//
//  Created by dragon on 3/31/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "NSManagedObject+Extra.h"

@implementation NSManagedObject (Extra)

+ (instancetype) object {
    NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
    return [self objectWithContext:context];
}

+ (instancetype) objectWithContext:(NSManagedObjectContext *)context {
    NSString *entityName = NSStringFromClass([self class]);
    NSEntityDescription *desc = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    return [[self alloc] initWithEntity:desc insertIntoManagedObjectContext:context];
}

@end
