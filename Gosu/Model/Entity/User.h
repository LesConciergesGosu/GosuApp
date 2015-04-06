//
//  User.h
//  Gosu
//
//  Created by dragon on 6/10/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contract, CreditCard, Message, Review, Task, Tutorial, UserProfile;

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * dataAvailable;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * myGosu;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSNumber * passwordReset;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * userType;
@property (nonatomic, retain) NSOrderedSet *cards;
@property (nonatomic, retain) Contract *contracts;
@property (nonatomic, retain) CreditCard *defaultCard;
@property (nonatomic, retain) NSOrderedSet *givenReviews;
@property (nonatomic, retain) Review *gotReviews;
@property (nonatomic, retain) NSOrderedSet *jobs;
@property (nonatomic, retain) NSOrderedSet *messages;
@property (nonatomic, retain) Contract *observations;
@property (nonatomic, retain) UserProfile *profile;
@property (nonatomic, retain) NSOrderedSet *requests;
@property (nonatomic, retain) NSOrderedSet *tasks;
@property (nonatomic, retain) Tutorial *tutorial;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)insertObject:(CreditCard *)value inCardsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCardsAtIndex:(NSUInteger)idx;
- (void)insertCards:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCardsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCardsAtIndex:(NSUInteger)idx withObject:(CreditCard *)value;
- (void)replaceCardsAtIndexes:(NSIndexSet *)indexes withCards:(NSArray *)values;
- (void)addCardsObject:(CreditCard *)value;
- (void)removeCardsObject:(CreditCard *)value;
- (void)addCards:(NSOrderedSet *)values;
- (void)removeCards:(NSOrderedSet *)values;
- (void)insertObject:(Review *)value inGivenReviewsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromGivenReviewsAtIndex:(NSUInteger)idx;
- (void)insertGivenReviews:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeGivenReviewsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInGivenReviewsAtIndex:(NSUInteger)idx withObject:(Review *)value;
- (void)replaceGivenReviewsAtIndexes:(NSIndexSet *)indexes withGivenReviews:(NSArray *)values;
- (void)addGivenReviewsObject:(Review *)value;
- (void)removeGivenReviewsObject:(Review *)value;
- (void)addGivenReviews:(NSOrderedSet *)values;
- (void)removeGivenReviews:(NSOrderedSet *)values;
- (void)insertObject:(Task *)value inJobsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromJobsAtIndex:(NSUInteger)idx;
- (void)insertJobs:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeJobsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInJobsAtIndex:(NSUInteger)idx withObject:(Task *)value;
- (void)replaceJobsAtIndexes:(NSIndexSet *)indexes withJobs:(NSArray *)values;
- (void)addJobsObject:(Task *)value;
- (void)removeJobsObject:(Task *)value;
- (void)addJobs:(NSOrderedSet *)values;
- (void)removeJobs:(NSOrderedSet *)values;
- (void)insertObject:(Message *)value inMessagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMessagesAtIndex:(NSUInteger)idx;
- (void)insertMessages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMessagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMessagesAtIndex:(NSUInteger)idx withObject:(Message *)value;
- (void)replaceMessagesAtIndexes:(NSIndexSet *)indexes withMessages:(NSArray *)values;
- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSOrderedSet *)values;
- (void)removeMessages:(NSOrderedSet *)values;
- (void)insertObject:(Task *)value inRequestsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRequestsAtIndex:(NSUInteger)idx;
- (void)insertRequests:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeRequestsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInRequestsAtIndex:(NSUInteger)idx withObject:(Task *)value;
- (void)replaceRequestsAtIndexes:(NSIndexSet *)indexes withRequests:(NSArray *)values;
- (void)addRequestsObject:(Task *)value;
- (void)removeRequestsObject:(Task *)value;
- (void)addRequests:(NSOrderedSet *)values;
- (void)removeRequests:(NSOrderedSet *)values;
- (void)insertObject:(Task *)value inTasksAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTasksAtIndex:(NSUInteger)idx;
- (void)insertTasks:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTasksAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTasksAtIndex:(NSUInteger)idx withObject:(Task *)value;
- (void)replaceTasksAtIndexes:(NSIndexSet *)indexes withTasks:(NSArray *)values;
- (void)addTasksObject:(Task *)value;
- (void)removeTasksObject:(Task *)value;
- (void)addTasks:(NSOrderedSet *)values;
- (void)removeTasks:(NSOrderedSet *)values;
@end
