//
//  PMessage.h
//  Gosu
//
//  Created by dragon on 3/28/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Parse/Parse.h>


FOUNDATION_EXPORT NSString *const kParseMessageClassKey;
// Field Keys
FOUNDATION_EXPORT NSString *const kParseMessageTaskKey;
FOUNDATION_EXPORT NSString *const kParseMessageAuthorKey;
FOUNDATION_EXPORT NSString *const kParseMessageTypeKey;
FOUNDATION_EXPORT NSString *const kParseMessageFileKey;
FOUNDATION_EXPORT NSString *const kParseMessageTextKey;
FOUNDATION_EXPORT NSString *const kParseMessageDateKey;
FOUNDATION_EXPORT NSString *const kParseMessageVoiceDurationKey;
FOUNDATION_EXPORT NSString *const kParseMessagePhotoWidthKey;
FOUNDATION_EXPORT NSString *const kParseMessagePhotoHeightKey;

@class PTask;
@interface PMessage : PFObject<PFSubclassing>

/*!
 @see MessageType
 */
@property MessageType type;

/*!
 @abstract In our app, the task means the chat room on an aspect.
 @see PTask
 */
@property (strong) PTask *task;

/*!
 @abstract sender (or author)
 @see PFUser
 */
@property (strong) PFUser *author;

/*!
 @abstract file attachment
 
 for MessageTypePhoto, Image (.png or .jpg)
 
 for MessageTypeAudio, Audio file (.wav)
 
 
 @see PFFile
 */
@property (strong) PFFile *file;


/*!
 @abstract text message
 
 used for MessageTypeText, MessageTypeNotification
 
 @see PFFile
 */
@property (strong) NSString *text;

/*!
 @abstract text message
 
 the time when the sender wrote this message. This time is different from 'createdAt'.
 
 @see PFFile
 */
@property (strong) NSDate *date;

@property int voiceDuration;

@property float photoWidth;
@property float photoHeight;

@end
