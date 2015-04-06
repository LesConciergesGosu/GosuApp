//
//  User+Extra.m
//  Gosu
//
//  Created by dragon on 3/31/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "User+Extra.h"
#import "CreditCard+Extra.h"
#import "UserProfile+Extra.h"
#import "GosuRelation+Extra.h"
#import "Notification+Extra.h"
#import "Task+Extra.h"
#import "Tutorial.h"

#import "PCreditCard.h"
#import "PNotification.h"
#import "PGosu.h"

#import "PFUser+Extra.h"
#import "PUserProfile.h"

#import "DataManager.h"

#import <Reachability/Reachability.h>
#import <CardIO/CardIO.h>

@implementation User (Extra)

+ (User *) currentUser {
    PFUser *user = [PFUser currentUser];
    if (user)
        return [[DataManager manager] managedObjectWithID:[user objectId] withEntityName:@"User"];
    
    return nil;
}

+ (User *) currentUserInContext:(NSManagedObjectContext *)context {
    PFUser *user = [PFUser currentUser];
    
    if (user)
        return [[DataManager manager] managedObjectWithID:[user objectId] withEntityName:@"User" inContext:context];
    
    return nil;
}

+ (instancetype) objectFromParseObject:(PFObject *)object inContext:(NSManagedObjectContext *)context
{
    if (!object)
        return nil;
    
    PFUser *pUser = (PFUser *)object;
    User *user = [[DataManager manager] managedObjectWithID:[pUser objectId]
                                             withEntityName:@"User"
                                                  inContext:context];
    
    
    [user fillInFromParseObject:pUser];
    
    return user;
}

- (void) fillInFromParseObject:(PFUser *)pUser {
    
    if ([pUser isDataAvailable]) {
        
        NSManagedObjectContext *context = self.managedObjectContext;
        
        if ([pUser.updatedAt isEqualToDate:self.updatedAt])
            return;
        
        if (![self.dataAvailable boolValue])
            self.dataAvailable = @(YES);
        
        if (![pUser.firstName isEqual:self.firstName])
            self.firstName = pUser.firstName;
        
        if (![pUser.lastName isEqual:self.lastName])
            self.lastName = pUser.lastName;
        
        if (![pUser.email isEqual:self.email])
            self.email = pUser.email;
        
        if (pUser.userType != [self.userType intValue])
            self.userType = @(pUser.userType);
        
        if (pUser.rating != [self.rating floatValue])
            self.rating = @(pUser.rating);
        
        if (pUser.photo && ![pUser.photo.url isEqual:self.photo])
            self.photo = [pUser.photo url];
        
        if (pUser.passwordReset != [self.passwordReset boolValue])
            self.passwordReset = @(pUser.passwordReset);
        
        if (![[pUser defaultCreditCard].objectId isEqualToString:[self defaultCard].objectId])
            self.defaultCard = [CreditCard objectFromParseObject:pUser.defaultCreditCard inContext:context];
        
        if (pUser.city && ![pUser.city isEqualToString:self.city])
            self.city = pUser.city;
        else if (!pUser.city && self.city)
            self.city = nil;
        
        if (pUser.sandboxUser != [self.sandboxUser boolValue])
            self.sandboxUser = @(pUser.sandboxUser);
        
        UserProfile *profile = [UserProfile objectFromParseObject:pUser.profile inContext:context];
        if (self.profile != profile)
            self.profile = profile;
        
        self.updatedAt = pUser.updatedAt;
    }
}

- (NSString *)fullName {
    
    if (self.firstName) {
        
        if (self.lastName)
            return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
        
        return self.firstName;
    }
    
    return @"";
}

- (Tutorial *)tutorialInstance {
    
    if (!self.tutorial) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tutorial" inManagedObjectContext:self.managedObjectContext];
        self.tutorial = [[Tutorial alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    }
    
    return self.tutorial;
}

#pragma mark Experience Management

- (NSArray *) fetchAllExperiences {
    
    NSArray *result = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Experience"];
    NSPredicate *predicate;
    
    predicate = [NSPredicate predicateWithFormat:@"customer == %@", self];
    
    request.predicate = predicate;
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:NO]];
    
    result = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    return result;
    
}

- (NSArray *) fetchExperiencesWithStatus:(NSArray *)statusArray skip:(NSUInteger)skip limit:(NSUInteger)limit
{
    NSArray *result = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Experience"];
    NSPredicate *predicate;
    
    if ([statusArray count] > 0)
    {
        predicate = [NSPredicate predicateWithFormat:@"customer == %@ AND status IN %@",
                     self, statusArray];
    }
    else
    {
        predicate = [NSPredicate predicateWithFormat:@"customer == %@",
                     self];
    }
    
    request.predicate = predicate;
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:NO]];
    request.fetchOffset = skip;
    
    if (limit > 0)
        request.fetchLimit = limit;
    
    result = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    return result;
}

- (NSArray *) fetchPendingExperiencesWithLimit:(NSUInteger)limit resultType:(NSFetchRequestResultType)resultType{
    
    NSArray *result = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Experience"];
    NSPredicate *predicate;
    
    predicate = [NSPredicate predicateWithFormat:@"status < %@ AND customer == %@",
                 @(ExperienceStatusConfirmed),
                 self];
    
    request.resultType = resultType;
    request.predicate = predicate;
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:NO]];
    
    if (limit > 0)
        request.fetchLimit = limit;
    
    result = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    return result;
}

- (NSArray *) fetchItineraryExperiencesWithLimit:(NSUInteger)limit resultType:(NSFetchRequestResultType)resultType
{
    NSArray *result = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Experience"];
    NSPredicate *predicate;
    
    predicate = [NSPredicate predicateWithFormat:@"status > %@ AND customer == %@",
                 @(ExperienceStatusCreated),
                 self];
    
    request.resultType = resultType;
    request.predicate = predicate;
    request.includesSubentities = YES;
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:NO]];
    
    if (limit > 0)
        request.fetchLimit = limit;
    
    result = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    return result;
}

- (NSArray *) fetchFinishedExperiencesWithLimit:(NSUInteger)limit resultType:(NSFetchRequestResultType)resultType{
    
    NSArray *result = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Experience"];
    NSPredicate *predicate;
    
    predicate = [NSPredicate predicateWithFormat:@"status >= %@ AND customer == %@",
                 @(TaskStatusFinished),
                 self];
    
    request.resultType = resultType;
    request.predicate = predicate;
    request.includesSubentities = YES;
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:NO]];
    
    if (limit > 0)
        request.fetchLimit = limit;
    
    result = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    return result;
}

#pragma mark Task Management

- (NSArray *) fetchAllTasks {
    return [self fetchAllTasksFrom:0 withLimit:0];
}

- (NSArray *) fetchAllTasksFrom:(NSUInteger)skip withLimit:(NSUInteger)limit {
    
    NSArray *result = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Task"];
    NSPredicate *predicate;
    
    if ([self.userType intValue] == UserTypeCustomer)
        predicate = [NSPredicate predicateWithFormat:@"customer == %@",
                     self];
    else
        predicate = [NSPredicate predicateWithFormat:@"ANY activeEmployees == %@",
                     self];
    
    request.predicate = predicate;
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:NO]];
    request.fetchOffset = skip;
    
    if (limit > 0)
        request.fetchLimit = limit;
    
    result = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    return result;
}

- (NSArray *) fetchTasksWithStatus:(NSArray *)statusArray skip:(NSUInteger)skip limit:(NSUInteger)limit 
{
    NSArray *result = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Task"];
    NSPredicate *predicate;
    
    if ([statusArray count] > 0)
    {
        if ([self.userType intValue] == UserTypeCustomer)
            predicate = [NSPredicate predicateWithFormat:@"customer == %@ AND status IN %@",
                         self, statusArray];
        else
            predicate = [NSPredicate predicateWithFormat:@"ANY activeEmployees == %@ AND status IN %@",
                         self, statusArray];
    }
    else
    {
        if ([self.userType intValue] == UserTypeCustomer)
            predicate = [NSPredicate predicateWithFormat:@"customer == %@",
                         self];
        else
            predicate = [NSPredicate predicateWithFormat:@"ANY activeEmployees == %@",
                         self];
    }
    
    request.predicate = predicate;
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:NO]];
    request.fetchOffset = skip;
    
    if (limit > 0)
        request.fetchLimit = limit;
    
    result = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    return result;
}

- (NSArray *) fetchOpenTasksWithLimit:(NSUInteger)limit {
    
    NSArray *result = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Task"];
    NSPredicate *predicate;
    
    if ([self.userType intValue] == UserTypeCustomer)
        predicate = [NSPredicate predicateWithFormat:@"status < %@ AND customer == %@",
                     @(TaskStatusFinished),
                     self];
    else
        predicate = [NSPredicate predicateWithFormat:@"status < %@ AND ANY activeEmployees == %@",
                     @(TaskStatusFinished),
                     self];
    
    request.predicate = predicate;
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO]];
    
    if (limit > 0)
        request.fetchLimit = limit;
    
    result = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    return result;
}

- (NSArray *) fetchFinishedTasksWithLimit:(NSUInteger)limit {
    
    NSArray *result = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Task"];
    NSPredicate *predicate;
    
    if ([self.userType intValue] == UserTypeCustomer)
        predicate = [NSPredicate predicateWithFormat:@"status >= %@ AND customer == %@",
                     @(TaskStatusFinished),
                     self];
    else
        predicate = [NSPredicate predicateWithFormat:@"status >= %@ AND ANY activeEmployees == %@",
                     @(TaskStatusFinished),
                     self];
    
    request.predicate = predicate;
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:NO]];
    
    if (limit > 0)
        request.fetchLimit = limit;
    
    result = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    return result;
}

- (NSInteger) countOfTaskHasNewMessages {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Task"];
    NSPredicate *predicate;
    
    if ([self.userType intValue] == UserTypeCustomer)
        predicate = [NSPredicate predicateWithFormat:@"unread > 0 AND customer == %@",
                     self];
    else
        predicate = [NSPredicate predicateWithFormat:@"unread > 0 AND ANY activeEmployees == %@",
                     self];
    
    request.predicate = predicate;
    
    return [self.managedObjectContext countForFetchRequest:request error:nil];
}

- (void) markAllMessagesReadWithCompletionHandler:(GSuccessWithErrorBlock)completion {
    
    NSManagedObjectID *userID = self.objectID;
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
        User *user = (User *)[context objectWithID:userID];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Task"];
        NSPredicate *predicate;
        
        if ([user.userType intValue] == UserTypeCustomer)
            predicate = [NSPredicate predicateWithFormat:@"unread > 0 AND customer == %@",
                         self];
        else
            predicate = [NSPredicate predicateWithFormat:@"unread > 0 AND ANY activeEmployees == %@",
                         self];
        
        request.predicate = predicate;
        
        NSArray *result = [context executeFetchRequest:request error:nil];
        for (Task *task in result) {
            task.unread = @(0);
        }
        
        if ([context hasChanges]) {
            [context saveRecursively];
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationUpdatedUnreadMessageCounts object:nil];
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES, nil);
            });
        }
    }];
    
}

#pragma mark Card Management


- (void) addCreditCard:(CardIOCreditCardInfo *)cardInfo
     CompletionHandler:(GSuccessWithErrorBlock)completion
{
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, @"Please check your internet connection.");
    } else {
        NSManagedObjectID *userID = self.objectID;
        [[DataManager manager] runInBackgroundWithBlock:^{
            PCreditCard *pCard = [PCreditCard object];
            pCard.cardNumber = cardInfo.cardNumber;
            pCard.expiryMonth = cardInfo.expiryMonth;
            pCard.expiryYear = cardInfo.expiryYear;
            pCard.ccv = cardInfo.cvv;
            
            NSError *error = nil;
            if ([pCard save:&error]) {
                
                NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
                [context performBlock:^{
                    User *user = (User *)[context objectWithID:userID];
                    if (user) {
                        CreditCard *card = [CreditCard objectFromParseObject:pCard inContext:context];
                        NSMutableArray *cards = [NSMutableArray arrayWithArray:[user.cards array]];
                        [cards addObject:card];
                        user.cards = [NSOrderedSet orderedSetWithArray:cards];
                        if ([user.cards count] == 1)
                            user.defaultCard = user.cards[0];
                        if ([context hasChanges])
                            [context saveRecursively];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(YES, nil);
                    });
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, ERROR_TO_STRING(error));
                });
            }
        }];
    }
}

- (void) removeCards:(NSArray *)aCards
   CompletionHandler:(GSuccessWithErrorBlock)completion{
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, @"Please check your internet connection.");
    } else {
        
        NSMutableArray *pCardsToRemove = [NSMutableArray array];
        for (CreditCard *aCard in aCards) {
            [pCardsToRemove addObject:[PCreditCard objectWithoutDataWithObjectId:aCard.objectId]];
        }
        
        [[DataManager manager] runInBackgroundWithBlock:^{
            NSError *error = nil;
            
            [PFObject deleteAll:pCardsToRemove error:nil];
            PFUser *pUser = [PFUser currentUser];
            [pUser refresh];
            
            PFQuery *query = [PCreditCard query];
            [query whereKey:kParseCreditCardUserKey equalTo:pUser];
            [query orderByDescending:@"createdAt"];
            NSArray *pCards = [query findObjects];
            
            NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
            [context performBlock:^{
                
                User *user = [User objectFromParseObject:pUser inContext:context];
                NSMutableArray *cards = [NSMutableArray arrayWithCapacity:[pCards count]];
                for (PCreditCard *pCard in pCards)
                    [cards addObject:[CreditCard objectFromParseObject:pCard inContext:context]];
                user.cards = [NSOrderedSet orderedSetWithArray:cards];
                
                [context saveRecursively];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(YES, error ? [error displayString] : nil);
                });
            }];
        }];
    }
}

- (void) removeCard:(CreditCard *)aCard
  CompletionHandler:(GSuccessWithErrorBlock)completion{
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, @"Please check your internet connection.");
    } else {
        NSManagedObjectID *cardID = aCard.objectID;
        NSManagedObjectID *userID = self.objectID;
        [[DataManager manager] runInBackgroundWithBlock:^{
            NSError *error = nil;
            [[PCreditCard objectWithoutDataWithObjectId:aCard.objectId] delete:&error];
            if (error == nil) {
                NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
                [context performBlock:^{
                    User *user = (User *)[context objectWithID:userID];
                    if (user) {
                        CreditCard *card = (CreditCard *)[context objectWithID:cardID];
                        NSMutableArray *cards = [NSMutableArray arrayWithArray:[user.cards array]];
                        [cards removeObject:card];
                        user.cards = [NSOrderedSet orderedSetWithArray:cards];
                        
                        if (user.defaultCard == card)
                            user.defaultCard = [cards count] > 0 ? cards[0] : nil;
                        
                        if ([context hasChanges])
                            [context saveRecursively];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(YES, nil);
                    });
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, ERROR_TO_STRING(error));
                });
            }
        }];
    }
}

- (void) setDefaultCard:(CreditCard *)aCard
      CompletionHandler:(GSuccessWithErrorBlock)completion {
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, @"Please check your internet connection.");
    } else {
        NSString *cardId = aCard.objectId;
        NSManagedObjectID *cardID = aCard.objectID;
        NSManagedObjectID *userID = self.objectID;
        [[DataManager manager] runInBackgroundWithBlock:^{
            NSError *error = nil;
            
            NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
            
            PFUser *pUser = [PFUser currentUser];
            pUser.defaultCreditCard = [PCreditCard objectWithoutDataWithObjectId:cardId];
            if ([pUser save:&error])
            {
                [context performBlock:^{
                    User *user = (User *)[context objectWithID:userID];
                    if (user) {
                        user.defaultCard = (CreditCard *)[context objectWithID:cardID];
                        if ([context hasChanges])
                            [context saveRecursively];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(YES, nil);
                    });
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, ERROR_TO_STRING(error));
                });
            }
        }];
    }
}



#pragma mark Gosu Relationship

- (BOOL) isGosu {
    return [self.myGosu boolValue];
}

- (NSArray *)gosuRelations
{
    NSArray *result = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"GosuRelation"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"from == %@", self];
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:YES]];
    result = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    return result;
}

- (void) removeGosuRelation:(GosuRelation *)pRelation
          completionHandler:(GSuccessWithErrorBlock)completion {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, @"Please check your internet connection.");
        return;
    }
    
    NSString *userId = self.objectId;
    NSString *relationId = pRelation.objectId;
    
    [[DataManager manager] runBlock:^{
        
        PGosu *pGosu = [PGosu objectWithoutDataWithObjectId:relationId];
        
        if ([pGosu delete]) {
            
            NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
            
            [context performBlock:^{
                
                GosuRelation *relation = [[DataManager manager] managedObjectWithID:relationId withEntityName:@"GosuRelation" inContext:context];
                User *currentUser = [User currentUserInContext:context];
                
                if (relation.from == currentUser) {
                    relation.to.myGosu = @(NO);
                }
                
                [context deleteObject:relation];
                
                // save the context
                [context saveRecursively];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(YES, nil);
                });
            }];
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                User *user = [[DataManager manager] managedObjectWithID:userId withEntityName:@"User"];
                [user pullGosuListWithCompletionHandler:completion];
            });
            
        }
        
    } inBackgroundWithIdentifier:QueueGosuList];
    
}

- (void) pullGosuListWithCompletionHandler:(GSuccessWithErrorBlock)completion {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, @"Please check your internet connection.");
        return;
    }
    
    PFUser *pUser = [PFUser objectWithoutDataWithObjectId:self.objectId];
    [[DataManager manager] runBlock:^{
        
        PFQuery *query = [PGosu query];
        [query whereKey:@"from" equalTo:pUser];
        [query includeKey:@"to"];
        
        NSError *error = nil;
        NSArray *array = [query findObjects:&error];
        
        if (error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(NO, ERROR_TO_STRING(error));
            });
            
            return;
        }

        NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];

        [context performBlock:^{

            User *currentUser = [User currentUserInContext:context];

            User *user = [[DataManager manager] managedObjectWithID:pUser.objectId
                                                     withEntityName:@"User"
                                                          inContext:context];
            // current cached tasks
            NSMutableArray *relations = [NSMutableArray arrayWithArray:[user gosuRelations]];

            // refresh tasks with the remote data
            for (PGosu *pRelation in array) {
                GosuRelation *relation = [GosuRelation objectFromParseObject:pRelation inContext:context];
                if (relation.from == currentUser) {
                    if ([relation.to.myGosu boolValue] != YES)
                        relation.to.myGosu = @(YES);
                }
                [relations removeObject:relation];
            }
            
            DLog(@"%d tasks have been refreshed", (int)[array count]);
            
            // remove the cached tasks that are not pulled from the server
            for (GosuRelation *relation in relations) {
                if (relation.from == currentUser) {
                    if ([relation.to.myGosu boolValue] != NO)
                        relation.to.myGosu = @(NO);
                }
                [context deleteObject:relation];
            }
            
            DLog(@"%d tasks have been deleted", (int)[[user gosuRelations] count]);

            // save the context
            if ([context hasChanges])
                [context saveRecursively];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(YES, nil);
            });
        }];
        
    } inBackgroundWithIdentifier:QueueGosuList];
}

#pragma mark Profile

- (void) refreshProfileWithCompletionHandler:(GSuccessWithErrorBlock)completion {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        
        if (completion) completion(NO, @"Please check your internet connection.");
        
    } else if (!self.profile) {
        
        if (completion) completion(NO, @"No profile.");
        
    }
    
    NSString *userId = self.objectId;
    
    [[DataManager manager] runBlock:^{
        
        NSError *error = nil;
        
        PUserProfile *pProfile = [PFCloud callFunction:@"refreshProfile"
                                        withParameters:@{
                                                         @"user":userId,
                                                         @"force":@(YES)}
                                                 error:&error];
        
        if (pProfile) {
            
            NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
            
            [context performBlock:^{
                
                User *user = (User *)[[DataManager manager] managedObjectWithID:userId withEntityName:@"User" inContext:context];
                
                if (user) {
                    
                    user.profile = (UserProfile *)[UserProfile objectFromParseObject:pProfile inContext:context];
                    
                    if ([context hasChanges]) {
                        
                        [context saveRecursively];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) completion(YES, nil);
                        });
                        
                        return;
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion(NO, @"No updates to pull");
                });
            }];
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(NO, ERROR_TO_STRING(error));
            });
        }
        
    } inBackgroundWithIdentifier:QueueProfile];
    
}

- (void) pullProfileWithCompletionHandler:(GSuccessWithErrorBlock)completion {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        
        completion(NO, @"Please check your internet connection.");
        
    } else if (!self.profile) {
        
        completion(NO, @"No profile.");
        
    } else {
        
        NSString *userId = self.objectId;
        NSString *profileId = self.profile.objectId;
        
        [[DataManager manager] runBlock:^{
            
            NSError *error = nil;
            NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
            
            PFQuery *query = [PUserProfile query];
            PUserProfile *pProfile = (PUserProfile *)[query getObjectWithId:profileId error:&error];
            
            if (pProfile) {
                [context performBlock:^{
                    
                    User *user = (User *)[[DataManager manager] managedObjectWithID:userId withEntityName:@"User" inContext:context];
                    
                    if (user) {
                        
                        user.profile = (UserProfile *)[UserProfile objectFromParseObject:pProfile inContext:context];
                        
                        if ([context hasChanges]) {
                            
                            [context saveRecursively];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completion(YES, nil);
                            });
                            
                            return;
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(NO, @"No updates to pull");
                    });
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, ERROR_TO_STRING(error));
                });
            }
            
        } inBackgroundWithIdentifier:QueueProfile];
    }
}

- (void) saveProfile:(PUserProfile *)pProfile
   completionHandler:(GSuccessWithErrorBlock)completion {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        
        completion(NO, @"Please check your internet connection.");
        
    } else {
        
        NSString *userId = self.objectId;
        NSManagedObjectID *userID = self.objectID;
        
        [[DataManager manager] runBlock:^{
            
            NSError *error = nil;
            NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
            
            PFUser *user = [PFUser objectWithoutDataWithObjectId:userId];
            user[kParseUserProfileKey] = pProfile;
            
            if ([user save:&error]) {
                
                [context performBlock:^{
                    User *user = (User *)[context objectWithID:userID];
                    if (user) {
                        user.profile = (UserProfile *)[UserProfile objectFromParseObject:pProfile inContext:context];
                        
                        if ([context hasChanges])
                            [context saveRecursively];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(YES, nil);
                    });
                }];
                
            } else {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, ERROR_TO_STRING(error));
                });
                
            }
            
        } inBackgroundWithIdentifier:QueueProfile];
    }
    
}

- (void) deleteNotification:(NSString *)notificationId completionHandler:(GSuccessWithErrorBlock)completion
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        
        completion(NO, @"Please check your internet connection.");
        
        return;
    }
    
    [[DataManager manager] runBlock:^{
        
        NSError *error = nil;
        
        PNotification *pNotify = [PNotification objectWithoutDataWithObjectId:notificationId];
        
        if ( ![pNotify delete:&error] ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(YES, nil);
            });
        }
        
        NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
        [context performBlock:^{
            
            Notification *notification = [[DataManager manager] findObjectWithID:notificationId withEntityName:@"Notification" inContext:context];
            
            if (notification)
                [context deleteObject:notification];
            
            if ([context hasChanges])
                [context saveRecursively];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(YES, nil);
            });
        }];
        
    } inBackgroundWithIdentifier:QueueNotificationList];
}

#pragma mark Notification

- (NSArray *)notifications
{
    NSArray *result = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Notification"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"to == %@", self];
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO]];
    result = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    return result;
}

- (NSInteger)countOfUnreadNotifications
{
    NSInteger result = 0;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Notification"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"to == %@", self]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"status == %@", @(NotificationStatusUnread)]];
    [request setIncludesSubentities:NO];
    
    result = [self.managedObjectContext countForFetchRequest:request error:nil];
    
    if (result == NSNotFound) {
        return 0;
    }
    
    return result;
}

- (void) pullNotificationsWithCompletionHandler:(GSuccessWithErrorBlock)completion {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, @"Please check your internet connection.");
        return;
    }
    
    PFUser *pUser = [PFUser objectWithoutDataWithObjectId:self.objectId];
    [[DataManager manager] runBlock:^{
        
        PFQuery *query = [PNotification query];
        [query whereKey:@"to" equalTo:pUser];
        [query includeKey:@"from"];
        [query orderByDescending:@"createdAt"];
        [query setLimit:100];
        
        NSError *error = nil;
        NSArray *array = [query findObjects:&error];
        
        if (error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(NO, ERROR_TO_STRING(error));
            });
            
            return;
            
        }
        
        NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
        
        [context performBlock:^{
            
            // refresh tasks with the remote data
            for (PNotification *pNotification in array) {
                [Notification objectFromParseObject:pNotification inContext:context];
            }
            
            if ([context hasChanges])
                [context saveRecursively];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion)
                    completion(YES, nil);
                else
                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNotificationListUpdated object:nil];
            });
            
        }];
        
    } inBackgroundWithIdentifier:QueueNotificationList];
}

- (void) readNotifications:(NSArray *)notifyIds completionHandler:(GSuccessWithErrorBlock)completion
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, @"Please check your internet connection.");
        return;
    }
    
    [[DataManager manager] runBlock:^{
        
        PFQuery *query = [PNotification query];
        [query whereKey:@"objectId" containedIn:notifyIds];
        
        NSError *error = nil;
        NSArray *array = [query findObjects:&error];
        
        if (error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(NO, ERROR_TO_STRING(error));
            });
            
            return;
            
        }
        
        for (PNotification *pNotify in array) {
            pNotify.status = NotificationStatusRead;
        }
        
        [PFObject saveAll:array error:&error];
        
        if (error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(NO, ERROR_TO_STRING(error));
            });
            
            return;
            
        }
        
        [PFObject fetchAll:array];
        
        NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
        
        [context performBlock:^{
            
            // refresh tasks with the remote data
            for (PNotification *pNotification in array) {
                [Notification objectFromParseObject:pNotification inContext:context];
            }
            
            if ([context hasChanges])
                [context saveRecursively];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion)
                    completion(YES, nil);
                else
                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNotificationListUpdated object:nil];
            });
            
        }];
        
    } inBackgroundWithIdentifier:QueueNotificationList];
}

@end
