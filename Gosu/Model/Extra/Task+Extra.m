//
//  Task+Extra.m
//  Gosu
//
//  Created by dragon on 3/31/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "Task+Extra.h"
#import "PTask.h"
#import "PReview.h"
#import "PContract.h"
#import "PCreditCard.h"
#import "PMessage.h"
#import "PExperience.h"

#import "CreditCard+Extra.h"
#import "User+Extra.h"
#import "Message+Extra.h"
#import "Experience+Extra.h"
#import "DataManager.h"

#import <Reachability/Reachability.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

static NSDictionary *typeColorMap = nil;

#define IGNORE_TIME 0.01

@implementation Task (Extra)

+ (instancetype) objectFromParseObject:(id)object inContext:(NSManagedObjectContext *)context
{
    if (!object)
        return nil;
    
    Task *res = nil;
    PTask *pTask = (PTask *)object;
    
    if (context && pTask.objectId) {
        res = [[DataManager manager] managedObjectWithID:pTask.objectId
                                                withEntityName:@"Task"
                                                     inContext:context];
        
    } else {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:[DataManager manager].managedObjectContext];
        res = [[Task alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    }
    
    [res fillInFromParseObject:pTask withContext:context];
    
    
    
    return res;
}

+ (void) createNewTaskPFObject:(PTask *)pTask completion:(GCreateObjectBlock)completion
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, nil, @"Please check your internet connection.");
        return;
    }
    
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        NSError *error = nil;
        
        PFACL *acl = [PFACL ACL];
        [acl setReadAccess:YES forUserId:@"*"];
        
        pTask.customer = [PFUser currentUser];
        pTask.status = TaskStatusCreated;
        pTask.ACL = acl;
        
        if ([pTask save:&error]) {
            
            NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
            
            [context performBlock:^{
                
                [Task objectFromParseObject:pTask inContext:context];
                
                [context saveRecursively];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(YES, pTask, nil);
                });
                
            }];
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, nil, ERROR_TO_STRING(error));
            });
        }
        
        DLog(@"error : %@", error);
        
    }];
}

+ (void) createNewTaskWithTitle:(NSString *)title
                    Description:(NSString *)desc
                          Hours:(int)hrs
                        Credits:(int)credits
                           Card:(CreditCard *)card
                     CardAmount:(int)amount
                  VoiceAttached:(NSString *)voicePath
              CompletionHandler:(GCreateObjectBlock)completion
{
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, nil, @"Please check your internet connection.");
        return;
    }
    
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        NSError *error = nil;
        
        PFACL *acl = [PFACL ACL];
        [acl setReadAccess:YES forUserId:@"*"];
        
        PTask *pTask = [PTask object];
        pTask.title = title;
        pTask.desc = desc;
        pTask.hours = hrs;
        pTask.card = [PCreditCard objectWithoutDataWithObjectId:card.objectId];
        pTask.customer = [PFUser currentUser];
        pTask.status = TaskStatusCreated;
        pTask.ACL = acl;
        
        if (voicePath != nil && [[NSFileManager defaultManager] fileExistsAtPath:voicePath])
        {
            PFFile *voiceFile =
                [PFFile fileWithName:[voicePath lastPathComponent] contentsAtPath:voicePath];
            
            if ([voiceFile save:&error]) {
                pTask.voice = voiceFile;
            }
            
            DLog(@"error : %@", error);
        }
        
        
        if ([pTask save:&error]) {
            
            NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
            
            [context performBlock:^{
                
                [Task objectFromParseObject:pTask inContext:context];
                
                [context saveRecursively];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(YES, pTask, nil);
                });
                
            }];
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, nil, ERROR_TO_STRING(error));
            });
        }
        
        DLog(@"error : %@", error);
        
    }];
}

+ (void) loadMyTasksWithCompletionHandler:(GSuccessWithErrorBlock)completion
{
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, @"Please check your internet connection.");
        return;
    }
    
    User *user = [User currentUser];
    UserType userType = [[user userType] intValue];
    
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        PFQuery *query = [PTask query];
        [query orderByDescending:@"updatedAt"];
        [query setLimit:1000];
        
        if (userType == UserTypeCustomer) {
            [query whereKey:kParseTaskCustomerKey equalTo:[PFUser currentUser]];
            [query includeKey:kParseTaskActiveEmployeesKey];
        } else {
            [query whereKey:kParseTaskActiveEmployeesKey equalTo:[PFUser currentUser]];
            [query includeKey:kParseTaskCustomerKey];
            [query includeKey:kParseTaskActiveEmployeesKey];
        }
        
        NSError *error = nil;
        NSArray *pTasks = [query findObjects:&error];
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, ERROR_TO_STRING(error));
            });
            return;
        }
        
        NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
        [context performBlock:^{
            
            User *currentUser = [User currentUserInContext:context];
            
            // current cached tasks
            NSMutableArray *tasks = [[currentUser fetchAllTasks] mutableCopy];
            
            // refresh tasks with the remote data
            for (PTask *pTask in pTasks) {
                Task * task = [Task objectFromParseObject:pTask inContext:context];
                [tasks removeObject:task];
            }
            
            DLog(@"%d tasks have been refreshed", (unsigned int)[pTasks count]);
            
            // remove the cached tasks that are not pulled from the server
            for (Task *task in tasks) {
                [context deleteObject:task];
            }
            
            DLog(@"%d tasks have been deleted", (int)[tasks count]);
            
            // save the context
            [context saveRecursively];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES, nil);
            });
        }];
    }];
}

+ (void) loadMyTasksWithStatus:(NSArray *)statusArray
             CompletionHandler:(GSuccessWithErrorBlock)completion {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, @"Please check your internet connection.");
        return;
    }
    
    User *user = [User currentUser];
    UserType userType = [[user userType] intValue];
    
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        PFQuery *query = [PTask query];
        [query orderByDescending:@"updatedAt"];
        [query setLimit:1000];
        
        if ([statusArray count] > 0)
            [query whereKey:kParseTaskStatusKey containedIn:statusArray];
        if (userType == UserTypeCustomer) {
            [query whereKey:kParseTaskCustomerKey equalTo:[PFUser currentUser]];
            [query includeKey:kParseTaskActiveEmployeesKey];
        } else {
            [query whereKey:kParseTaskActiveEmployeesKey equalTo:[PFUser currentUser]];
            [query includeKey:kParseTaskCustomerKey];
            [query includeKey:kParseTaskActiveEmployeesKey];
        }
        
        NSError *error = nil;
        NSArray *pTasks = [query findObjects:&error];
        
        DLog(@"tasks : %d", (int)[pTasks count]);
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, ERROR_TO_STRING(error));
            });
            return;
        }
        
        NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
        [context performBlock:^{
            
            User *currentUser = [User currentUserInContext:context];
            
            // current cached tasks
            NSMutableArray *tasks = [[currentUser fetchTasksWithStatus:statusArray skip:0 limit:0] mutableCopy];
            
            // refresh tasks with the remote data
            for (PTask *pTask in pTasks) {
                Task * task = [Task objectFromParseObject:pTask inContext:context];
                [tasks removeObject:task];
            }
            
            DLog(@"%d tasks have been refreshed", (int)[pTasks count]);
            
            // remove the cached tasks that are not pulled from the server
            for (Task *task in tasks) {
                [context deleteObject:task];
            }
            
            DLog(@"%d tasks have been deleted", (int)[tasks count]);
            
            // save the context
            if ([context hasChanges])
                [context saveRecursively];
            else
                [context reset];

            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES, nil);
            });
        }];
    }];
}

+ (void) refreshTasks:(NSArray *)taskArray
    CompletionHandler:(GSuccessWithErrorBlock)completion {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, @"Please check your internet connection.");
        return;
    }
    
    User *user = [User currentUser];
    UserType userType = [[user userType] intValue];
    
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        PFQuery *query = [PTask query];
        [query orderByDescending:@"updatedAt"];
        [query whereKey:@"objectId" containedIn:taskArray];
            
        if (userType == UserTypeCustomer) {
            [query whereKey:kParseTaskCustomerKey equalTo:[PFUser currentUser]];
            [query includeKey:kParseTaskActiveEmployeesKey];
        } else {
            [query whereKey:kParseTaskActiveEmployeesKey equalTo:[PFUser currentUser]];
            [query includeKey:kParseTaskCustomerKey];
            [query includeKey:kParseTaskActiveEmployeesKey];
        }
        
        NSError *error = nil;
        NSArray *pTasks = [query findObjects:&error];
        
        DLog(@"tasks : %d", (int)[pTasks count]);
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, ERROR_TO_STRING(error));
            });
            return;
        }
        
        NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
        [context performBlock:^{
            
            // refresh tasks with the remote data
            for (PTask *pTask in pTasks) {
                [Task objectFromParseObject:pTask inContext:context];
            }
            
            DLog(@"%d tasks have been refreshed", (int)[pTasks count]);
            
            // save the context
            if ([context hasChanges])
                [context saveRecursively];
            else
                [context reset];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES, nil);
            });
        }];
    }];
    
}

+ (void) refreshUnreadMessagesForAllTasksSince:(NSDate *)since
                             CompletionHandler:(GSuccessWithErrorBlock)completion
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, @"Please check your internet connection.");
        return;
    }
    
    UserType userType = [[[User currentUser] userType] intValue];
    [[DataManager manager] runBlock:^{
        
        PFQuery *taskQuery = [PTask query];
        PFQuery *msgQuery = [PMessage query];
        [taskQuery orderByAscending:@"updatedAt"];
        [taskQuery setLimit:1000];
        
        if (userType == UserTypeCustomer) {
            [taskQuery whereKey:kParseTaskCustomerKey equalTo:[PFUser currentUser]];
            [msgQuery includeKey:@"task.activeEmployees"];
        } else {
            [taskQuery whereKey:kParseTaskActiveEmployeesKey equalTo:[PFUser currentUser]];
            [msgQuery includeKey:@"task.customer"];
            [msgQuery includeKey:@"task.activeEmployees"];
        }
        
        [msgQuery whereKey:@"task" matchesQuery:taskQuery];
        [msgQuery orderByAscending:@"createdAt"];
        if (since)
            [msgQuery whereKey:@"createdAt" greaterThan:since];
        
        NSInteger index = 0;
        NSMutableArray *taskIDs = [NSMutableArray array];
        NSMutableArray *pTasks = [NSMutableArray array];
        for (;;) {
            
            msgQuery.skip = index * 500;
            msgQuery.limit = 500;
            
            NSArray *pMsgs = [msgQuery findObjects];
            
            for (PMessage *pMsg in pMsgs) {
                NSString *taskId = pMsg.task.objectId;
                if (![taskIDs containsObject:taskId]) {
                    [taskIDs addObject:taskId];
                    [pTasks addObject:pMsg.task];
                }
            }
            
            if ([pMsgs count] < 500)
                break;
            
            index ++;
        }
        
        NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
        [context performBlock:^{
            
            NSMutableArray *tasks = [NSMutableArray array];
            for (PTask *pTask in pTasks) {
                
                Task *task = [Task objectFromParseObject:pTask inContext:context];
                NSDate *maxCreatedAt = [task.messages valueForKeyPath:@"@max.createdAt"];
                
                if (maxCreatedAt) {
                    [tasks addObject:@{@"task":pTask.objectId, @"lastDate":maxCreatedAt}];
                } else {
                    [tasks addObject:@{@"task":pTask.objectId}];
                }
            }
            
            if ([context hasChanges])
                [context saveRecursively];
            
            [[DataManager manager] runInBackgroundWithBlock:^{
                
                NSInteger index = 0;
                NSMutableArray *results = [NSMutableArray array];
                
                while (index * 5 < [tasks count]) {
                    
                    NSInteger count = MIN([tasks count] - index * 5, 5);
                    NSArray *array = [tasks subarrayWithRange:NSMakeRange(index * 5, count)];
                    
                    NSError *error = nil;
                    NSArray *result = [PFCloud callFunction:CloudFetchNewMessageCounts
                                             withParameters:@{@"tasks":array}
                                                      error:&error];
                    
                    if (error)
                        DLog(@"error : %@", [error localizedDescription]);
                    
                    if ([result count] > 0)
                        [results addObjectsFromArray:result];
                    
                    index ++;
                }
                
                if ([results count] == 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) completion(YES, nil);
                    });
                    return;
                }
                
                NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
                
                [context performBlock:^{
                    
                    // refresh tasks with the remote data
                    for (NSDictionary *res in results) {
                        Task *task = [[DataManager manager] managedObjectWithID:res[@"task"] withEntityName:@"Task" inContext:context];
                        task.unread = res[@"unread"];
                    }
                    
                    // save the context
                    if ([context hasChanges])
                        [context saveRecursively];
                    else
                        [context reset];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(YES, nil);
                    });
                }];
                
            }];
            
        }];
        
    } inBackgroundWithIdentifier:@"refreshUnreadMessages"];
    
}

+ (void) loadJobsWithCompletionHandler:(GSuccessWithErrorBlock)completion {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, @"Please check your internet connection.");
        return;
    }
    
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        NSError *error = nil;
        NSArray *pJobs = [PFCloud callFunction:CloudGetJobs withParameters:@{} error:&error];
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, ERROR_TO_STRING(error));
            });
            return;
        }
        
        NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
        [context performBlock:^{
            
            User *user = [User currentUserInContext:context];
            
            NSMutableArray *tasks = [NSMutableArray array];
            
            for (PTask *pTask in pJobs) {
                Task *task = [Task objectFromParseObject:pTask inContext:context];
                [tasks addObject:task];
            }
            
            user.jobs = [NSOrderedSet orderedSetWithArray:tasks];
            
            [context saveRecursively];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES, nil);
            });
        }];
    }];
}

+ (UIColor *)colorForType:(NSString *)type
{
    if (typeColorMap == nil)
    {
        UIColor *travelColor = [UIColor colorWithRed:22/255.f green:160/255.f blue:133/255.f alpha:1];
        UIColor *entertainColor = [UIColor colorWithRed:192/255.f green:57/255.f blue:43/255.f alpha:1];
        UIColor *foodColor = [UIColor colorWithRed:243/255.f green:156/255.f blue:18/255.f alpha:1];
        typeColorMap = @{
                         TASK_TYPE_ACCOMODATION:[UIColor colorWithRed:41/255.f green:128/255.f blue:185/255.f alpha:1],
                         TASK_TYPE_TRAVEL:travelColor,
                         TASK_TYPE_FLIGHT:travelColor,
                         TASK_TYPE_RENTAL:travelColor,
                         TASK_TYPE_LIMO:travelColor,
                         TASK_TYPE_TAXI:travelColor,
                         TASK_TYPE_FOOD:foodColor,
                         TASK_TYPE_FOOD_TAPAS:foodColor,
                         TASK_TYPE_FOOD_FUSION:foodColor,
                         TASK_TYPE_FOOD_HOMESTYLE:foodColor,
                         TASK_TYPE_FOOD_ETHNIC:foodColor,
                         TASK_TYPE_ENTERTAINMENT:entertainColor,
                         TASK_TYPE_SPORTS:entertainColor,
                         TASK_TYPE_THEATRE:entertainColor,
                         TASK_TYPE_CONCERTS:entertainColor,
                         TASK_TYPE_NIGHTLIFE:entertainColor,
                         TASK_TYPE_MOVIE:entertainColor,
                         TASK_TYPE_GIFT:[UIColor colorWithRed:142/255.f green:68/255.f blue:173/255.f alpha:1]};
    }
    
    UIColor *res = [typeColorMap objectForKey:type];
    res = res ?: [UIColor whiteColor];
    
    return res;
}

+ (UIImage *)iconForType:(NSString *)type subType:(NSString *)subType
{
    NSString *iconName = [type isEqualToString:TASK_TYPE_FOOD] ? @"food" : ( subType ?: type);
    iconName = [NSString stringWithFormat:@"task_icon_%@", iconName];
    return [UIImage imageNamed:iconName];
}

+ (NSString *)shortTitleForType:(NSString *)type subType:(NSString *)subType
{
    if ([type isEqualToString:TASK_TYPE_FOOD])
        return @"RESTUARANT";
    
    return subType ? [subType uppercaseString] : [type uppercaseString];
}

+ (NSString *)commonTitleForType:(NSString *)type subType:(NSString *)subType
{
    
    NSString *res = @"";
    
    if ([type isEqual:TASK_TYPE_FOOD])
    {
        res = @"Find me a Restaurant";
    }
    else if ([type isEqualToString:TASK_TYPE_TRAVEL])
    {
        if ([subType isEqual:TASK_TYPE_FLIGHT])
            res = @"Book a Flight";
        else if ([subType isEqual:TASK_TYPE_LIMO])
            res = @"Book a Limo";
        else if ([subType isEqual:TASK_TYPE_RENTAL])
            res = @"Book a Rental Car";
        else if ([subType isEqual:TASK_TYPE_TAXI])
            res = @"Book a Taxi";
    }
    else if ([type isEqual:TASK_TYPE_ACCOMODATION])
    {
        res = @"Book Accommodations";
    }
    else if ([type isEqual:TASK_TYPE_GIFT])
    {
        res = @"Find a Gift";
    }
    else if ([type isEqualToString:TASK_TYPE_ENTERTAINMENT])
    {
        if ([subType isEqual:TASK_TYPE_SPORTS])
            res = @"Find an Event";
        else if ([subType isEqual:TASK_TYPE_THEATRE])
            res = @"Find Theatre Tickets";
        else if ([subType isEqual:TASK_TYPE_CONCERTS])
            res = @"Find Concert Tickets";
        else if ([subType isEqual:TASK_TYPE_NIGHTLIFE])
            res = @"Find an Event";
        else if ([subType isEqual:TASK_TYPE_MOVIE])
            res = @"Find Movie Tickets";
    }
    
    return res;
}

- (NSString *)navigationTitle
{
    
    NSString *res = @"";
    
    if (self.offerId)
    {
        res = [Task commonTitleForType:self.type subType:self.type2];
    }
    else
    {
        if ([self.type isEqualToString:TASK_TYPE_FLIGHT])
            res = [NSString stringWithFormat:@"Flight to %@", self.title];
        else
            res = [Task commonTitleForType:self.type subType:self.type2];
    }
    
    return [res uppercaseString];
}

- (void) fillInFromParseObject:(PTask *)pTask withContext:(NSManagedObjectContext *)context
{
    if ([pTask isDataAvailable]) {
        
        if ([pTask.updatedAt isEqualToDate:self.updatedAt])
            return;
        
        if (![pTask.title isEqualToString:self.title])
            self.title = pTask.title;
        
        if (![pTask.desc isEqualToString:self.desc])
            self.desc = pTask.desc;
        
        if (pTask.status != [self.status intValue])
            self.status = @(pTask.status);
        
        if (pTask.hours != [self.hours intValue])
            self.hours = @(pTask.hours);
        
        if (![pTask.createdAt isEqualToDate:self.createdAt])
            self.createdAt = pTask.createdAt;
        
        if (pTask.card) {
            CreditCard *creditCard = [CreditCard objectFromParseObject:pTask.card inContext:context];
            if (creditCard != self.card)
                self.card = creditCard;
        } else {
            if (self.card != nil)
                self.card = nil;
        }
        
        if (pTask.note && ![pTask.note isEqualToString:self.note])
            self.note = pTask.note;
        
        if (pTask.note2 && ![pTask.note2 isEqualToString:self.note2])
            self.note2 = pTask.note2;
        
        if (pTask.note3 && ![pTask.note3 isEqualToString:self.note3])
            self.note3 = pTask.note3;
        
        if (pTask.note4 && ![pTask.note4 isEqualToString:self.note4])
            self.note4 = pTask.note4;
        
        if (pTask.date && ![pTask.date isEqualToDate:self.date])
            self.date = pTask.date;
        
        if (pTask.date2 && ![pTask.date2 isEqualToDate:self.date2])
            self.date2 = pTask.date2;
        
        if (pTask.location)
        {
            self.latitude = @(pTask.location.latitude);
            self.longitude = @(pTask.location.longitude);
        }
        
        if (pTask.location2)
        {
            self.latitude2 = @(pTask.location2.latitude);
            self.longitude2 = @(pTask.location2.longitude);
        }
        
        if (pTask.type && ![pTask.type isEqualToString:self.type])
            self.type = pTask.type;
        
        if (pTask.type2 && ![pTask.type2 isEqualToString:self.type2])
            self.type2 = pTask.type2;
        
        if (pTask.type3 && ![pTask.type3 isEqualToString:self.type3])
            self.type3 = pTask.type3;
        
        if (pTask.asap != [self.asap boolValue])
            self.asap = @(pTask.asap);
        
        if (pTask.priceLevel != [self.priceLevel intValue])
            self.priceLevel = @(pTask.priceLevel);
        
        if (pTask.lowerPrice != [self.lowerPrice floatValue])
            self.lowerPrice = @(pTask.lowerPrice);
        
        if (pTask.upperPrice != [self.upperPrice floatValue])
            self.upperPrice = @(pTask.upperPrice);
        
        if (pTask.numberOfPersons != [self.numberOfPersons intValue])
            self.numberOfPersons = @(pTask.numberOfPersons);
        
        if (pTask.numberOfAdults != [self.numberOfAdults intValue])
            self.numberOfAdults = @(pTask.numberOfAdults);
        
        if (pTask.numberOfChildren != [self.numberOfChildren intValue])
            self.numberOfChildren = @(pTask.numberOfChildren);
        
        if (pTask.numberOfInfants != [self.numberOfInfants intValue])
            self.numberOfInfants = @(pTask.numberOfInfants);
        
        if (pTask.photoUrl && ![pTask.photoUrl isEqualToString:self.photoUrl])
            self.photoUrl = pTask.photoUrl;
        
        if (pTask.offerId && ![pTask.offerId isEqualToString:self.offerId])
            self.offerId = pTask.offerId;
        
        if (pTask.address && ![pTask.address isEqualToString:self.address])
            self.address = pTask.address;
        
        if (pTask.customer && self.managedObjectContext)
            self.customer = [User objectFromParseObject:pTask.customer inContext:context];
        
        if (pTask.activeEmployees) {
            
            NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSet];
            
            for (PFUser *pEmployee in pTask.activeEmployees) {
                User *employee = [User objectFromParseObject:pEmployee inContext:self.managedObjectContext];
                
                if ([employee isInserted])
                    [self.managedObjectContext processPendingChanges];
                
                [set addObject:employee];
            }
            
            self.activeEmployees = set;
        }
        
        self.updatedAt = pTask.updatedAt;
        
        self.changed = NO;
    }
}

- (void) fillInFromParseObject:(PTask *)pTask {
    
    [self fillInFromParseObject:pTask withContext:self.managedObjectContext];
}

- (User *)mainWorker
{
    NSOrderedSet *activeEmployees = [self valueForKey:@"activeEmployees"];
    if ([activeEmployees count] > 0)
        return [activeEmployees objectAtIndex:0];
    
    return nil;
}

#pragma mark For Review

- (void)fetchReviewsTodoWithCompletionHandler:(GArrayBlock)completion {
    
    NSString *objectId = self.objectId;
    
    __weak typeof (self) wself = self;
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        Task *sself = wself;
        
        if (sself) {
            
            NSError *error = nil;
            NSArray *response = [PFCloud callFunction:CloudGetReviewListTodo withParameters:@{@"task":objectId} error:&error];
            
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, ERROR_TO_STRING(error));
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(response, nil);
                });
            }
        }
        
    }];
}

- (void)rateWithReviews:(NSArray *)reviews CompletionHandler:(GSuccessWithErrorBlock)completion {
    
    
    //BOOL isCustomer = self.customer == [User currentUser];
    
    __weak Task *wself = self;
    
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        __weak Task *sself = wself;
        
        NSError *error = nil;
        
        NSDictionary *parameter = @{@"task":sself.objectId, @"reviews":reviews};
        
        id response = [PFCloud callFunction:CloudRateExperiences withParameters:parameter error:&error];
        
        if (!error) {
            
            if ([response isKindOfClass:[PTask class]]) {
                
                PTask *pTask = (PTask *)response;
                
                NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
                
                __weak typeof (self) wself = sself;
                [context performBlock:^{
                    
                    Task *sself = wself;
                    
                    if (sself)
                        [sself fillInFromParseObject:pTask];
                    
                    [context saveRecursively];
                    
                    if (completion) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(YES, ERROR_TO_STRING(error));
                        });
                    }
                }];
                
            } else {
                
                if (completion) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(YES, ERROR_TO_STRING(error));
                    });
                }
            }
            
        } else if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, ERROR_TO_STRING(error));
            });
        }
    }];
}

#pragma mark for Customers

- (void) deleteTaskWithCompletionHandler:(GSuccessWithErrorBlock)completion {
    
    NSString *taskId = self.objectId;
    
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        NSError *error = nil;
        
        NSDictionary *result = [PFCloud callFunction:CloudDeleteTask withParameters:@{@"task":taskId} error:&error];
        
        if (!error) {
            
            NSArray *experiences = result[@"experiences"];
            
            NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
            
            [context performBlock:^{
                
                Task *task = [[DataManager manager] managedObjectWithID:taskId
                                                         withEntityName:@"Task"
                                                              inContext:context];
                
                if (task)
                    [context deleteObject:task];
                
                // refresh the experiences related with the task deleted
                for (PExperience *experience in experiences)
                    [Experience objectFromParseObject:experience inContext:context];
                
                [context saveRecursively];
                
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

- (void) editJobPostingWithTitle:(NSString *)title
                     Description:(NSString *)desc
                   VoiceAttached:(NSString *)voicePath
               CompletionHandler:(GCreateObjectBlock)completion
{
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, nil, @"Please check your internet connection.");
        return;
    }
    
    NSString *parseId = self.objectId;
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        NSError *error = nil;
        NSDictionary *params = @{@"task":parseId,
                                 @"title":title,
                                 @"desc":desc};
        
        PTask *pTask = [PFCloud callFunction:CloudEditTaskDescription
                              withParameters:params
                                       error:&error];
        
        if (error) {
            
            DLog(@"error : %@", error);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, nil, ERROR_TO_STRING(error));
            });
            
            return;
        }
        
        NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
        
        [context performBlock:^{
            
            Task *task = [[DataManager manager] findObjectWithID:parseId withEntityName:@"Task" inContext:context];
            task.title = pTask.title;
            task.desc = pTask.desc;
            
            [context saveRecursively];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES, pTask, nil);
            });
            
        }];
    }];
}

#pragma mark for Employees

- (void) ignoreJobPostingWithCompletionHandler:(GSuccessWithErrorBlock)completion {
    
    NSString *parseId = self.objectId;
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        NSError *error = nil;
        
        PTask *pTask = [PFCloud callFunction:CloudIgnoreJobPosting withParameters:@{@"task":parseId} error:&error];
        
        if (!error) {
            
            if (pTask) {
                
                NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
                
                [context performBlock:^{
                    
                    // remove the ignored job posting from my job list.
                    User *user = [User currentUserInContext:context];
                    
                    NSMutableArray *jobPostings = [NSMutableArray arrayWithArray:[user.jobs array]];
                    
                    NSInteger i = 0;
                    while (i < [jobPostings count]) {
                        Task *task = jobPostings[i];
                        if ([task.objectId isEqualToString:pTask.objectId]) {
                            [jobPostings removeObject:task];
                            continue;
                        }
                        i ++;
                    }
                    
                    user.jobs = [NSOrderedSet orderedSetWithArray:jobPostings];
                    
                    [context saveRecursively];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(YES, nil);
                    });
                }];
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(YES, nil);
                });
            }
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, ERROR_TO_STRING(error));
            });
            
        }
    }];
}

- (void) acceptTaskWithCompletionHandler:(GSuccessWithErrorBlock)completion {
    
    NSString *parseId = self.objectId;
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        NSError *error = nil;
        
        PTask *pTask = [PFCloud callFunction:CloudAcceptTask withParameters:@{@"task":parseId} error:&error];
        if (!error) {
            
            if (pTask) {
                
                NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
                [context performBlock:^{
                    
                    // save task
                    Task *task = [Task objectFromParseObject:pTask inContext:context];
                    
                    User *user = [User currentUserInContext:context];
                    
                    // put into hired list
                    NSMutableArray *tasks = [NSMutableArray arrayWithArray:[user.jobs array]];
                    [tasks removeObject:task];
                    user.jobs = [NSOrderedSet orderedSetWithArray:tasks];
                    
                    [context saveRecursively];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(YES, nil);
                    });
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(YES, nil);
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, ERROR_TO_STRING(error));
            });
        }
    }];
}

- (void) deliverTaskWithCompletionHandler:(GSuccessWithErrorBlock)completion {
    
    NSString *parseId = self.objectId;
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        NSError *error = nil;
        
        PTask *pTask = [PFCloud callFunction:CloudDeliverTask withParameters:@{@"task":parseId} error:&error];
        
        if (!error) {
            
            NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
            
            [context performBlock:^{
                
                [Task objectFromParseObject:pTask inContext:context];
                
                [context saveRecursively];
                
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

- (void) resignTaskWithCompletionHandler:(GSuccessWithErrorBlock)completion {
    
    NSString *parseId = self.objectId;
    
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        NSError *error = nil;
        
        PTask *pTask = [PFCloud callFunction:CloudResignTask withParameters:@{@"task":parseId} error:&error];
        
        if (!error) {
            
            if (pTask) {
                
                NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
                
                [context performBlock:^{
                    
                    Task *task = [[DataManager manager] managedObjectWithID:parseId
                                                             withEntityName:@"Task"
                                                                  inContext:context];
                    
                    if (task)
                        [context deleteObject:task];
                    
                    [context saveRecursively];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(YES, nil);
                    });
                }];
            }
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, ERROR_TO_STRING(error));
            });
            
        }
    }];
    
}

- (void)willTurnIntoFault
{
    //DLog(@"Task turns into fault: %@", self );
    [super willTurnIntoFault];
}

#pragma mark Fetch Message

- (void) refreshCountOfUnreadMessagesWithCompletionHandler:(GSuccessWithErrorBlock)completion {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, @"Please check your internet connection.");
        return;
    }
    
    NSDictionary *param;
    NSDate *maxCreatedAt = [self.messages valueForKeyPath:@"@max.createdAt"];
    
    if (maxCreatedAt) {
        param = @{@"task":self.objectId, @"lastDate":maxCreatedAt};
    } else {
        param = @{@"task":self.objectId};
    }
    
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        NSError *error = nil;
        NSArray *results = [PFCloud callFunction:CloudFetchNewMessageCounts
                                  withParameters:@{@"tasks":@[param]}
                                           error:&error];
        
        if (error) {
            if (completion) completion(NO, ERROR_TO_STRING(error));
            return;
        }
        
        NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
        
        [context performBlock:^{
            
            // refresh tasks with the remote data
            for (NSDictionary *res in results) {
                Task *task = [[DataManager manager] managedObjectWithID:res[@"task"] withEntityName:@"Task" inContext:context];
                task.unread = res[@"unread"];
            }
            
            // save the context
            if ([context hasChanges])
                [context saveRecursively];
            else
                [context reset];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES, nil);
            });
        }];
        
    }];
}

- (void) fetchMessagesSince:(NSDate *)sinceDate
          completionHandler:(GIntBlock)completion {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(0, @"Please check your internet connection.");
        return;
    }
    
    NSManagedObjectID *taskID = [self objectID];
    NSString *taskParseID = [self objectId];
    
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        // get Parse Task object
        PTask *pTask = [PTask objectWithoutDataWithObjectId:taskParseID];
        
        NSError *error = nil;
        PFQuery *query = [PMessage query];
        [query whereKey:kParseMessageTaskKey equalTo:pTask];
        if (sinceDate)
            [query whereKey:@"createdAt" greaterThan:sinceDate];
        [query orderByAscending:@"createdAt"];
        
        // get the total number of messages for this task
        NSInteger totalNumberOfEntries = [query countObjects:&error];
        
        if (error) {
            completion(0, ERROR_TO_STRING(error));
            return;
        }
        
        if (totalNumberOfEntries == 0) {
            // don't need to fetch any messages
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(0, nil);
            });
            return;
        }
        
        DLog(@"Retrieving Mesages");
        NSInteger theLimit = totalNumberOfEntries;
        if (totalNumberOfEntries>MAX_MESSAGES_LOADED_ONCE) {
            theLimit = MAX_MESSAGES_LOADED_ONCE;
        }
        
        [query includeKey:@"author"];
        query.limit = theLimit; // count of messages need to be fetched now
        NSArray *newMessages = [query findObjects:&error];
        
        // now we need to merge the local messages with new fetched messages
        // local messages contain the draft messages as well, so
        // 1. we need to replace the draft message with real mesaage
        // 2. insert new message(from others) at appropriate order.
        NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
        
        [context performBlock:^{
            
            Task *task = (Task *)[context objectWithID:taskID];
            
            [task mergeMessagesWithNew:newMessages];
            
            if ([context hasChanges])
                [context saveRecursively];
            
            NSUInteger countOfNewMessages = [newMessages count];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(countOfNewMessages, nil);
            });
        }];
        
        return;
        
    }];
}


- (void) fetchMessagesWithSkip:(NSInteger)skipCount
             CompletionHandler:(GIntBlock)completion {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable)
    {
        completion(0, @"Please check your internet connection.");
        return;
    }
    
    NSManagedObjectID *taskID = [self objectID];
    NSString *taskParseID = [self objectId];
    
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        // get Parse Task object
        PTask *pTask = [PTask objectWithoutDataWithObjectId:taskParseID];
        
        NSError *error = nil;
        PFQuery *query = [PMessage query];
        [query whereKey:kParseMessageTaskKey equalTo:pTask];
        [query orderByAscending:@"createdAt"];
        
        // get the total number of messages for this task
        NSInteger totalNumberOfEntries = [query countObjects:&error];
        
        if (error) {
            completion(0, ERROR_TO_STRING(error));
            return;
        }
        
        if (totalNumberOfEntries <= skipCount) {
            // don't need to fetch any messages
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(0, nil);
            });
            return;
        }
        
        DLog(@"Retrieving Mesages");
        NSInteger theLimit;
        if (totalNumberOfEntries-skipCount>MAX_MESSAGES_LOADED_ONCE) {
            theLimit = MAX_MESSAGES_LOADED_ONCE;
        } else {
            theLimit = totalNumberOfEntries-skipCount;
        }
        
        [query includeKey:@"author"];
        query.skip = skipCount; // count of messages had been fetched laready
        query.limit = theLimit; // count of messages need to be fetched now
        NSArray *newMessages = [query findObjects:&error];
        
        // now we need to merge the local messages with new fetched messages
        // local messages contain the draft messages as well, so
        // 1. we need to replace the draft message with real mesaage
        // 2. insert new message(from others) at appropriate order.
        NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
        
        [context performBlock:^{
            
            Task *task = (Task *)[context objectWithID:taskID];
            
            [task mergeMessagesWithNew:newMessages];
            
            if ([context hasChanges])
                [context saveRecursively];
            
            NSUInteger countOfNewMessages = [newMessages count];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(countOfNewMessages, nil);
            });
        }];
        
        return;
        
    }];
}

- (void) mergeMessagesWithNew:(NSArray *)pMessages {
    
    if ([pMessages count] == 0)
        return;
    
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *newMessages = [pMessages sortedArrayUsingDescriptors:@[sd]];
    
    NSManagedObjectContext *context = self.managedObjectContext;
    
    // all messages
    NSMutableArray *messages = [NSMutableArray arrayWithArray:[self.messages array]];
    
    // calculate skip count
    NSDate *stableDate = [NSDate dateWithTimeInterval:-IGNORE_TIME sinceDate:[(PMessage *)newMessages[0] date]];
    NSInteger stableCount = 0;
    for (NSInteger i = 0; i < [messages count]; i ++) {
        Message *msg = messages[i];
        if ([msg.date compare:stableDate] != NSOrderedAscending) {
            stableCount = i;
            break;
        }
    }
    
    NSInteger index = stableCount;
    NSInteger nIndex = 0;
    
    while (index < [messages count] && nIndex < [newMessages count]) {
        
        Message *draft = messages[index];
        PMessage *pMessage = newMessages[nIndex];
        
        NSComparisonResult compare = NSOrderedSame;
        
        if ([[pMessage.author objectId] isEqualToString:[draft author].objectId]) {
        // same sender
            NSTimeInterval interval = [draft.date timeIntervalSinceDate:pMessage.date];
            
            if (fabs(interval) < IGNORE_TIME)
                compare = NSOrderedSame;
            else if (interval < 0)
                compare = NSOrderedAscending;
            else
                compare = NSOrderedDescending;
            
        } else {
        // different sender
            compare = [draft.date compare:pMessage.date];
            compare = compare == NSOrderedSame ? NSOrderedDescending : compare;
        }
        
        
        if (compare == NSOrderedDescending) {
            // insert the new message at current index (index).
            Message *newMsg = [Message objectFromParseObject:pMessage inContext:context];
            [messages insertObject:newMsg atIndex:index];
            index ++;
            nIndex ++;
        } else if (compare == NSOrderedSame) {
            // replace the draft message with new one.
            [draft fillInFromParseObject:pMessage];
            draft.draft = @(NO);
            index ++;
            nIndex ++;
        } else { // NSOrderedAscending
            index ++;
        }
    }
    
    for (NSInteger i = nIndex; i < [newMessages count]; i++) {
        Message *newMsg = [Message objectFromParseObject:newMessages[i] inContext:context];
        newMsg.draft = @(NO);
        [messages addObject:newMsg];
    }
    
    self.messages = [NSOrderedSet orderedSetWithArray:messages];
}

#pragma mark - 
- (NSDictionary *)PFObject
{
    PTask *res = [PTask objectWithoutDataWithObjectId:self.objectId];
    
    if (self.title) res.title = self.title;
    if (self.desc) res.desc = self.desc;
    res.status = [self.status integerValue];
    res.hours = [self.hours intValue];
    if (self.card)
        res.card = [PCreditCard objectWithoutDataWithObjectId:self.card.objectId];
    
    if (self.note) res.note = self.note;
    if (self.note2) res.note2 = self.note2;
    if (self.note3) res.note3 = self.note3;
    if (self.note4) res.note4 = self.note4;
    if (self.date) res.date = self.date;
    if (self.date2) res.date2 = self.date2;
    
    if ([self.latitude doubleValue] != 0 && [self.longitude doubleValue] != 0)
        res.location = [PFGeoPoint geoPointWithLatitude:[self.latitude doubleValue] longitude:[self.longitude doubleValue]];
    
    if ([self.latitude2 doubleValue] != 0 && [self.longitude2 doubleValue] != 0)
        res.location2 = [PFGeoPoint geoPointWithLatitude:[self.latitude2 doubleValue] longitude:[self.longitude2 doubleValue]];
    
    if (self.type) res.type = self.type;
    if (self.type2) res.type2 = self.type2;
    if (self.type3) res.type3 = self.type3;
    res.asap = [self.asap boolValue];
    res.priceLevel = [self.priceLevel intValue];
    res.lowerPrice = [self.lowerPrice floatValue];
    res.upperPrice = [self.upperPrice floatValue];
    
    res.numberOfPersons = [self.numberOfPersons intValue];
    res.numberOfAdults = [self.numberOfAdults intValue];
    res.numberOfChildren = [self.numberOfChildren intValue];
    res.numberOfInfants = [self.numberOfInfants intValue];
    if (self.photoUrl) res.photoUrl = self.photoUrl;
    if (self.offerId) res.offerId = self.offerId;
    if (self.address) res.address = self.address;
    res.changed = NO;
    
    return res;
}

@end
