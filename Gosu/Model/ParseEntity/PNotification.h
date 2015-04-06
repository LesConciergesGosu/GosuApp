//
//  PNotification.h
//  Gosu
//
//  Created by dragon on 6/14/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Parse/Parse.h>
// Class Key
FOUNDATION_EXPORT NSString *const kParseNotificationClassKey;

@class PTask;
@interface PNotification : PFObject<PFSubclassing>

@property (strong) NSString *message;
@property int status;
@property int type;
@property (strong) PTask *task;
@property (strong) PFUser *to;
@property (strong) PFUser *from;
@end
