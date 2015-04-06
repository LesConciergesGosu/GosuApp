//
//  Task.h
//  Gosu
//
//  Created by Dragon on 11/26/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contract, CreditCard, Experience, Message, Review, User;

@interface Task : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * asap;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDate * date2;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * hours;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * latitude2;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * longitude2;
@property (nonatomic, retain) NSNumber * lowerPrice;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * note2;
@property (nonatomic, retain) NSString * note3;
@property (nonatomic, retain) NSString * note4;
@property (nonatomic, retain) NSNumber * numberOfAdults;
@property (nonatomic, retain) NSNumber * numberOfChildren;
@property (nonatomic, retain) NSNumber * numberOfInfants;
@property (nonatomic, retain) NSNumber * numberOfPersons;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * offerId;
@property (nonatomic, retain) NSString * photoUrl;
@property (nonatomic, retain) NSNumber * priceLevel;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * type2;
@property (nonatomic, retain) NSString * type3;
@property (nonatomic, retain) NSNumber * unread;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * upperPrice;
@property (nonatomic, retain) NSOrderedSet *activeEmployees;
@property (nonatomic, retain) CreditCard *card;
@property (nonatomic, retain) NSOrderedSet *contracts;
@property (nonatomic, retain) User *customer;
@property (nonatomic, retain) Experience *experience;
@property (nonatomic, retain) NSOrderedSet *explorers;
@property (nonatomic, retain) NSOrderedSet *messages;
@property (nonatomic, retain) NSOrderedSet *reviews;

@property (nonatomic, strong) NSArray *recommendations;
@property (nonatomic) BOOL changed;
@end

@interface Task (CoreDataGeneratedAccessors)

- (void)insertObject:(User *)value inActiveEmployeesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromActiveEmployeesAtIndex:(NSUInteger)idx;
- (void)insertActiveEmployees:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeActiveEmployeesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInActiveEmployeesAtIndex:(NSUInteger)idx withObject:(User *)value;
- (void)replaceActiveEmployeesAtIndexes:(NSIndexSet *)indexes withActiveEmployees:(NSArray *)values;
- (void)addActiveEmployeesObject:(User *)value;
- (void)removeActiveEmployeesObject:(User *)value;
- (void)addActiveEmployees:(NSOrderedSet *)values;
- (void)removeActiveEmployees:(NSOrderedSet *)values;
- (void)insertObject:(Contract *)value inContractsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromContractsAtIndex:(NSUInteger)idx;
- (void)insertContracts:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeContractsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInContractsAtIndex:(NSUInteger)idx withObject:(Contract *)value;
- (void)replaceContractsAtIndexes:(NSIndexSet *)indexes withContracts:(NSArray *)values;
- (void)addContractsObject:(Contract *)value;
- (void)removeContractsObject:(Contract *)value;
- (void)addContracts:(NSOrderedSet *)values;
- (void)removeContracts:(NSOrderedSet *)values;
- (void)insertObject:(User *)value inExplorersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromExplorersAtIndex:(NSUInteger)idx;
- (void)insertExplorers:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeExplorersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInExplorersAtIndex:(NSUInteger)idx withObject:(User *)value;
- (void)replaceExplorersAtIndexes:(NSIndexSet *)indexes withExplorers:(NSArray *)values;
- (void)addExplorersObject:(User *)value;
- (void)removeExplorersObject:(User *)value;
- (void)addExplorers:(NSOrderedSet *)values;
- (void)removeExplorers:(NSOrderedSet *)values;
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
- (void)insertObject:(Review *)value inReviewsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromReviewsAtIndex:(NSUInteger)idx;
- (void)insertReviews:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeReviewsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInReviewsAtIndex:(NSUInteger)idx withObject:(Review *)value;
- (void)replaceReviewsAtIndexes:(NSIndexSet *)indexes withReviews:(NSArray *)values;
- (void)addReviewsObject:(Review *)value;
- (void)removeReviewsObject:(Review *)value;
- (void)addReviews:(NSOrderedSet *)values;
- (void)removeReviews:(NSOrderedSet *)values;
@end
