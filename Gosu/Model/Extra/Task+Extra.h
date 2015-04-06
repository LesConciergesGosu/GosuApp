//
//  Task+Extra.h
//  Gosu
//
//  Created by dragon on 3/31/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "Task.h"
#import "EntityProtocol.h"

@class PTask;
@interface Task (Extra)<EntityProtocol>


+ (void) createNewTaskPFObject:(PTask *)pTask completion:(GCreateObjectBlock)completion;

/**
 Post a task.
 
 Create PTask object with the information passed, upload to the backend.
 */
+ (void) createNewTaskWithTitle:(NSString *)title
                    Description:(NSString *)desc
                          Hours:(int)hrs
                        Credits:(int)credits
                           Card:(CreditCard *)card
                     CardAmount:(int)amount
                  VoiceAttached:(NSString *)voicePath
              CompletionHandler:(GCreateObjectBlock)completion;


/**
 Pull the tasks I've posted or hired in.
 */
+ (void) loadMyTasksWithCompletionHandler:(GSuccessWithErrorBlock)completion;

+ (void) loadMyTasksWithStatus:(NSArray *)statusArray
             CompletionHandler:(GSuccessWithErrorBlock)completion;

+ (void) refreshTasks:(NSArray *)taskArray
    CompletionHandler:(GSuccessWithErrorBlock)completion;

+ (void) refreshUnreadMessagesForAllTasksSince:(NSDate *)since
                  CompletionHandler:(GSuccessWithErrorBlock)completion;


/**
 Pull the open tasks that I can apply on.
 
 After success, user->jobs is changed.
 */
+ (void) loadJobsWithCompletionHandler:(GSuccessWithErrorBlock)completion;

#pragma mark UI Relations
+ (UIColor *)colorForType:(NSString *)type;
+ (UIImage *)iconForType:(NSString *)type subType:(NSString *)subType;
+ (NSString *)shortTitleForType:(NSString *)type subType:(NSString *)subType;
+ (NSString *)commonTitleForType:(NSString *)type subType:(NSString *)subType;
- (NSString *)navigationTitle;

#pragma mark for Review

- (void)fetchReviewsTodoWithCompletionHandler:(GArrayBlock)completion;

/**
 request the following to the parse server.
 
 1. mark the task as reviewed.
 
 2. mark all contracts as reviewed.
 
 3. save all reviews of the contracts.
 
 @param reviews
        {
            @"task":"taskid"
            @"reviews":[{
                @"contract":"contract id",
                @"toUser":"toUser id",
                @"rating":"rating float value",
                @"gosu":"boolean",
                }
            ...]
        }
*/
- (void)rateWithReviews:(NSArray *)reviews CompletionHandler:(GSuccessWithErrorBlock)completion;


/**
 first active employee
 */
- (User *)mainWorker;

#pragma mark for Customers
- (void) deleteTaskWithCompletionHandler:(GSuccessWithErrorBlock)completion;
- (void) editJobPostingWithTitle:(NSString *)title
                     Description:(NSString *)desc
                   VoiceAttached:(NSString *)voicePath
               CompletionHandler:(GCreateObjectBlock)completion;

#pragma mark for Employees

- (void) ignoreJobPostingWithCompletionHandler:(GSuccessWithErrorBlock)completion;

- (void) acceptTaskWithCompletionHandler:(GSuccessWithErrorBlock)completion;

- (void) deliverTaskWithCompletionHandler:(GSuccessWithErrorBlock)completion;

- (void) resignTaskWithCompletionHandler:(GSuccessWithErrorBlock)completion;

#pragma mark Fetch Messages

- (void) refreshCountOfUnreadMessagesWithCompletionHandler:(GSuccessWithErrorBlock)completion;

/**
 Fetch messages from skip point
 
 This method should be called in main thread
 */
- (void) fetchMessagesSince:(NSDate *)sinceDate
          completionHandler:(GIntBlock)completion;
- (void) fetchMessagesWithSkip:(NSInteger)skipCount
             CompletionHandler:(GIntBlock)completion;

#pragma mark -
- (PTask *)PFObject;

@end
