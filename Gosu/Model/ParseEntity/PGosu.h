//
//  PGosu.h
//  Gosu
//
//  Created by dragon on 4/18/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Parse/Parse.h>
// Class Key
FOUNDATION_EXPORT NSString *const kParseGosuClassKey;

@class PReview;
@interface PGosu : PFObject<PFSubclassing>

@property (strong) PFUser *from;
@property (strong) PFUser *to;
@property (strong) PReview *review;
@end
