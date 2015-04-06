//
//  PUserProfile.h
//  Gosu
//
//  Created by dragon on 5/22/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Parse/Parse.h>

@interface PUserProfile : PFObject<PFSubclassing>

@property (strong) NSArray *family;
@property (strong) NSArray *favorites;
@property (strong) NSArray *general;
@property (strong) PFUser *owner;
@property int savedHours;
@property int countOfCompletedTasks;
@property int countOfOngoingTasks;

@end
