//
//  Message+Extra.h
//  Gosu
//
//  Created by dragon on 3/31/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "Message.h"
#import "EntityProtocol.h"

@class PMessage;
@interface Message (Extra)<EntityProtocol>

/**
 Send Text message and return the Core Data object for that.
 
 This function should be called in main thread.
 */
+ (Message *) sendMessage:(NSString *)text
                  forTask:(Task *)task
               fromAuthor:(User *)user
    withCompletionHandler:(GSuccessWithErrorBlock)completion;

/**
 Send Photo message and return the Core Data object for that.
 
 This function should be called in main thread.
 */
+ (Message *) sendPhoto:(UIImage *)image
                forTask:(Task *)task
             fromAuthor:(User *)user
  withCompletionHandler:(GSuccessWithErrorBlock)completion;

/**
 */
+ (Message *) sendPhoto:(UIImage *)image
            withQuality:(CGFloat)quality
                forTask:(Task *)task
             fromAuthor:(User *)user
  withCompletionHandler:(GSuccessWithErrorBlock)completion;

/**
 Send Voice message and return the Core Data object for that.
 
 This function should be called in main thread.
 */
+ (Message *) sendVoice:(NSString *)voicePath
                forTask:(Task *)task
             fromAuthor:(User *)user
           withDuration:(NSTimeInterval)duration
      CompletionHandler:(GSuccessWithErrorBlock)completion;

@end
