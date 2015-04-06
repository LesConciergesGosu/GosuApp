//
//  Experience+Extra.m
//  Gosu
//
//  Created by Dragon on 11/14/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "Experience+Extra.h"
#import "Task+Extra.h"
#import "User+Extra.h"
#import "Offer+Extra.h"
#import "PExperience.h"
#import "PTask.h"
#import "DataManager.h"
#import <Reachability/Reachability.h>
#import <Parse/Parse.h>

@implementation Experience (Extra)

+ (instancetype) objectFromParseObject:(id)object inContext:(NSManagedObjectContext *)context
{
    if (!object)
        return nil;
    
    PExperience *pExperience = (PExperience *)object;
    Experience *res = [[DataManager manager] managedObjectWithID:pExperience.objectId
                                            withEntityName:@"Experience"
                                                 inContext:context];
    
    [res fillInFromParseObject:pExperience];
    
    return res;
}

- (void) fillInFromParseObject:(PExperience *)pExperience {
    
    if ([pExperience isDataAvailable]) {
        
        if ([pExperience.updatedAt isEqualToDate:self.updatedAt])
            return;
        
        self.updatedAt = pExperience.updatedAt;
        
        if (![pExperience.createdAt isEqualToDate:self.createdAt])
            self.createdAt = pExperience.createdAt;
        
        if (![pExperience.title isEqualToString:self.title])
            self.title = pExperience.title;
        
        if (pExperience.status != [self.status integerValue])
            self.status = @(pExperience.status);
        
        User *user = [User objectFromParseObject:pExperience.customer inContext:self.managedObjectContext];;
        
        if (user != self.customer)
            self.customer = user;
        
        if (pExperience.tasks) {
            
            NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSet];
            
            for (PTask *pTask in pExperience.tasks) {
                
                Task *task = [Task objectFromParseObject:pTask inContext:self.managedObjectContext];
                
                if ([task isInserted])
                    [self.managedObjectContext processPendingChanges];
                
                [set addObject:task];
            }
            
            if (![set isEqualToOrderedSet:self.tasks])
                self.tasks = set;
        }
    }
}

+ (void)confirmExperienceWithId:(NSString *)exprienceId WithPFTasks:(NSArray *)pTasks completion:(GCreateObjectBlock)completion
{
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (PTask *task in pTasks)
    {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        for (NSString *key in task.allKeys)
        {
            id object = [task objectForKey:key];
            
            if ([object isKindOfClass:[PFObject class]])
            {
                NSDictionary *entity = @{@"objectId":[(PFObject *)object objectId],
                                         @"class":[(PFObject *)object parseClassName]};
                
                [dictionary setObject:entity forKey:key];
            }
            else if (![object isKindOfClass:[PFACL class]])
            {
                [dictionary setObject:object forKey:key];
            }
        }
        
        [array addObject:dictionary];
    }
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, nil, @"Please check your internet connection.");
        return;
    }
    
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        NSError *error = nil;
        
        PExperience *pExperience = [PFCloud callFunction:@"confirmExperience"
                                          withParameters:@{@"tasks":array, @"experience":exprienceId}
                                                   error:&error];
        
        if (pExperience)
        {
            NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
            
            [context performBlock:^{
                
                [Experience objectFromParseObject:pExperience inContext:context];
                
                if ([context hasChanges])
                    [context saveRecursively];
                
                dispatch_async_on_main_queue(completion, YES, pExperience, nil);
                
            }];
        }
        else
        {
            DLog(@"error : %@", error);
            
            dispatch_async_on_main_queue(completion, NO, nil, ERROR_TO_STRING(error));
        }
        
    }];
}

+ (void)editExperienceWithId:(NSString *)exprienceId WithPFTasks:(NSArray *)pTasks completion:(GCreateObjectBlock)completion
{
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (PTask *task in pTasks)
    {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        for (NSString *key in task.allKeys)
        {
            id object = [task objectForKey:key];
            
            if ([object isKindOfClass:[PFObject class]])
            {
                NSDictionary *entity = @{@"objectId":[(PFObject *)object objectId],
                                         @"class":[(PFObject *)object parseClassName]};
                
                [dictionary setObject:entity forKey:key];
            }
            else if (![object isKindOfClass:[PFACL class]])
            {
                [dictionary setObject:object forKey:key];
            }
        }
        
        [array addObject:dictionary];
    }
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, nil, @"Please check your internet connection.");
        return;
    }
    
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        NSError *error = nil;
        
        PExperience *pExperience = [PFCloud callFunction:@"editExperience"
                                          withParameters:@{@"tasks":array, @"experience":exprienceId}
                                                   error:&error];
        
        if (pExperience)
        {
            NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
            
            [context performBlock:^{
                
                [Experience objectFromParseObject:pExperience inContext:context];
                
                if ([context hasChanges])
                    [context saveRecursively];
                
                dispatch_async_on_main_queue(completion, YES, pExperience, nil);
                
            }];
        }
        else
        {
            DLog(@"error : %@", error);
            
            dispatch_async_on_main_queue(completion, NO, nil, ERROR_TO_STRING(error));
        }
        
    }];
}

+ (void)createExperienceWithPFTasks:(NSArray *)pTasks completion:(GCreateObjectBlock)completion
{
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (PTask *task in pTasks)
    {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        for (NSString *key in task.allKeys)
        {
            id object = [task objectForKey:key];
            
            if ([object isKindOfClass:[PFObject class]])
            {
                NSDictionary *entity = @{@"objectId":[(PFObject *)object objectId],
                                         @"class":[(PFObject *)object parseClassName]};
                
                [dictionary setObject:entity forKey:key];
            }
            else if (![object isKindOfClass:[PFACL class]])
            {
                [dictionary setObject:object forKey:key];
            }
        }
        
        [array addObject:dictionary];
    }
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, nil, @"Please check your internet connection.");
        return;
    }
    
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        NSError *error = nil;
        
        PExperience *pExperience = [PFCloud callFunction:@"createExperience"
                                          withParameters:@{@"tasks":array}
                                                   error:&error];
        
        if (pExperience)
        {
            NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
            
            [context performBlock:^{
                
                [Experience objectFromParseObject:pExperience inContext:context];
                
                if ([context hasChanges])
                    [context saveRecursively];
                
                dispatch_async_on_main_queue(completion, YES, pExperience, nil);
                
            }];
        }
        else
        {
            DLog(@"error : %@", error);
            
            dispatch_async_on_main_queue(completion, NO, nil, ERROR_TO_STRING(error));
        }
        
    }];
}

+ (void) createExperienceWithOffer:(Offer *)offer completion:(GCreateObjectBlock)completion
{
    [Experience createExperienceWithPFTasks:@[[offer task]] completion:completion];
}

+ (void) loadMyExperiencesWithCompletionHandler:(GSuccessWithErrorBlock)completion
{
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, @"Please check your internet connection.");
        return;
    }
    
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        PFQuery *query = [PExperience query];
        [query orderByDescending:@"updatedAt"];
        [query setLimit:1000];
        
        [query whereKey:@"customer" equalTo:[PFUser currentUser]];
        [query includeKey:@"tasks"];
        [query includeKey:@"tasks.activeEmployees"];
        
        NSError *error = nil;
        NSArray *pExperiences = [query findObjects:&error];
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, ERROR_TO_STRING(error));
            });
            return;
        }
        
        NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
        [context performBlock:^{
            
            User *currentUser = [User currentUserInContext:context];
            
            // current cached experiences
            NSMutableArray *experiences = [[currentUser fetchAllExperiences] mutableCopy];
            
            // refresh experiences with the remote data
            for (PExperience *pExperience in pExperiences) {
                
                Experience *experience = [Experience objectFromParseObject:pExperience inContext:context];
                [experiences removeObject:experience];
            }
            
            DLog(@"%d tasks have been refreshed", (unsigned int)[pExperiences count]);
            
            // remove the cached tasks that are not pulled from the server
            for (Experience *experience in experiences) {
                [context deleteObject:experience];
            }
            
            DLog(@"%d tasks have been deleted", (int)[experiences count]);
            
            // save the context
            [context saveRecursively];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES, nil);
            });
        }];
    }];
}

+ (void) loadMyExperiencesWithStatus:(NSArray *)statusArray
             CompletionHandler:(GSuccessWithErrorBlock)completion {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, @"Please check your internet connection.");
        return;
    }
    
    
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        PFQuery *query = [PExperience query];
        [query orderByDescending:@"updatedAt"];
        [query setLimit:1000];
        
        [query whereKey:@"customer" equalTo:[PFUser currentUser]];
        [query includeKey:@"tasks"];
        
        if ([statusArray count] > 0)
            [query whereKey:@"status" containedIn:statusArray];
        
        
        NSError *error = nil;
        NSArray *pExperiences = [query findObjects:&error];
        
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
            NSMutableArray *experiences = [[currentUser fetchExperiencesWithStatus:statusArray skip:0 limit:0] mutableCopy];
            
            // refresh tasks with the remote data
            for (PExperience *pExperience in pExperiences) {
                Experience * experience = [Experience objectFromParseObject:pExperience inContext:context];
                [experiences removeObject:experience];
            }
            
            DLog(@"%d tasks have been refreshed", (int)[pExperiences count]);
            
            // remove the cached tasks that are not pulled from the server
            for (Experience * experience in experiences) {
                [context deleteObject:experience];
            }
            
            DLog(@"%d tasks have been deleted", (int)[experiences count]);
            
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

@end
