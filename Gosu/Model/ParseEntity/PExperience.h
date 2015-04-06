//
//  PExperience.h
//  Gosu
//
//  Created by Dragon on 11/8/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Parse/Parse.h>

@interface PExperience : PFObject<PFSubclassing>

@property (strong) NSString *title;
@property (strong) NSArray *tasks;

@property (strong) PFUser *customer;

@property ExperienceStatus status;
@end
