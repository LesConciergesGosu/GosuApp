//
//  PMessage.m
//  Gosu
//
//  Created by dragon on 3/28/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "PMessage.h"
#import <Parse/PFObject+Subclass.h>


NSString *const kParseMessageClassKey = @"Message";

NSString *const kParseMessageTaskKey = @"task";
NSString *const kParseMessageAuthorKey = @"author";
NSString *const kParseMessageTypeKey = @"type";
NSString *const kParseMessageFileKey = @"file";
NSString *const kParseMessageTextKey = @"text";
NSString *const kParseMessageDateKey = @"date";
NSString *const kParseMessageVoiceDurationKey = @"voiceDuration";
NSString *const kParseMessagePhotoWidthKey = @"photoWidth";
NSString *const kParseMessagePhotoHeightKey = @"photoHeight";

@implementation PMessage
@dynamic task;
@dynamic author;
@dynamic file;
@dynamic text;
@dynamic type;
@dynamic date;
@dynamic voiceDuration;
@dynamic photoWidth;
@dynamic photoHeight;

+ (NSString *)parseClassName {
    return kParseMessageClassKey;
}

@end
