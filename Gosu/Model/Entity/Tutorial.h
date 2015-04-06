//
//  Tutorial.h
//  Gosu
//
//  Created by dragon on 5/22/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Tutorial : NSManagedObject

@property (nonatomic, retain) NSNumber * createTask;
@property (nonatomic, retain) NSNumber * fundSlider;
@property (nonatomic, retain) User *owner;

@end
