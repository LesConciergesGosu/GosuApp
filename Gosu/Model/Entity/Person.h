//
//  Person.h
//  Gosu
//
//  Created by dragon on 5/23/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Person : NSManagedObject

@property (nonatomic, retain) NSManagedObject *owner;

@end
