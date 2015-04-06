//
//  User+Extra.h
//  Gosu
//
//  Created by dragon on 3/31/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "User.h"
#import "EntityProtocol.h"

@class CreditCard;
@class Tutorial;
@class PUserProfile;
@class GosuRelation;
@class CardIOCreditCardInfo;
@interface User (Extra)<EntityProtocol>

/**
 current logged in user in main context.
 */
+ (User *) currentUser;

/**
 current logged in user in the context.
 */
+ (User *) currentUserInContext:(NSManagedObjectContext *)context;


#pragma mark Card Management
/**
 add credit card and sync to the parse server.
 */
- (void) addCreditCard:(CardIOCreditCardInfo *)cardInfo
     CompletionHandler:(GSuccessWithErrorBlock)completion;

/**
 remove a card and sync to the parse server
 */
- (void) removeCard:(CreditCard *)aCard
  CompletionHandler:(GSuccessWithErrorBlock)completion;

- (void) removeCards:(NSArray *)aCards
   CompletionHandler:(GSuccessWithErrorBlock)completion;

/**
 remove a card and sync to the parse server
 */
- (void) setDefaultCard:(CreditCard *)aCard
      CompletionHandler:(GSuccessWithErrorBlock)completion;

#pragma mark Profile
/**
 pull profile
 */
- (void) refreshProfileWithCompletionHandler:(GSuccessWithErrorBlock)completion;
- (void) pullProfileWithCompletionHandler:(GSuccessWithErrorBlock)completion;
- (void) saveProfile:(PUserProfile *)pProfile
   completionHandler:(GSuccessWithErrorBlock)completion;

- (NSString *)fullName;

- (Tutorial *)tutorialInstance;

#pragma mark Gosu Relationship
- (BOOL) isGosu;
- (NSArray *)gosuRelations;
- (void) removeGosuRelation:(GosuRelation *)relation
          completionHandler:(GSuccessWithErrorBlock)completion;
- (void) pullGosuListWithCompletionHandler:(GSuccessWithErrorBlock)completion;

#pragma mark Task Management
- (NSArray *) fetchAllExperiences;
- (NSArray *) fetchExperiencesWithStatus:(NSArray *)statusArray skip:(NSUInteger)skip limit:(NSUInteger)limit;
- (NSArray *) fetchPendingExperiencesWithLimit:(NSUInteger)limit resultType:(NSFetchRequestResultType)resultType;
- (NSArray *) fetchItineraryExperiencesWithLimit:(NSUInteger)limit resultType:(NSFetchRequestResultType)resultType;
- (NSArray *) fetchFinishedExperiencesWithLimit:(NSUInteger)limit resultType:(NSFetchRequestResultType)resultType;

// Fetch tasks from local db
- (NSArray *) fetchAllTasks;
- (NSArray *) fetchAllTasksFrom:(NSUInteger)skip withLimit:(NSUInteger)limit;
- (NSArray *) fetchTasksWithStatus:(NSArray *)statusArray skip:(NSUInteger)skip limit:(NSUInteger)limit;
- (NSArray *) fetchOpenTasksWithLimit:(NSUInteger)limit;
- (NSArray *) fetchFinishedTasksWithLimit:(NSUInteger)limit;
- (NSInteger) countOfTaskHasNewMessages;
- (void) markAllMessagesReadWithCompletionHandler:(GSuccessWithErrorBlock)completion;

#pragma mark Notification

- (NSArray *)notifications;
- (NSInteger)countOfUnreadNotifications;
- (void) pullNotificationsWithCompletionHandler:(GSuccessWithErrorBlock)completion;
- (void) readNotifications:(NSArray *)notificationIds completionHandler:(GSuccessWithErrorBlock)completion;
- (void) deleteNotification:(NSString *)notificationId completionHandler:(GSuccessWithErrorBlock)completion;

@end
