//
//  NSManagedObjectContext+Extra.m
//  Gosu
//
//  Created by dragon on 4/3/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "NSManagedObjectContext+Extra.h"
#import "DataManager.h"

static NSString const * kThreadManagedContextKey = @"ThreadManagedContext";

@implementation NSManagedObjectContext (Extra)

+ (NSManagedObjectContext *)contextForCurrentThread {
    
    NSManagedObjectContext *mainContext = [[DataManager manager] managedObjectContext];
    
    if ([NSThread isMainThread])
    {
        return mainContext;
    }
    else
    {
        NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
        NSManagedObjectContext *res = [threadDictionary objectForKey:kThreadManagedContextKey];
        
        if (res == nil)
        {
//            DLog(@"Create New Managed Object Context");
            res = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            res.mergePolicy = [[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyStoreTrumpMergePolicyType];
            //res.persistentStoreCoordinator = [DataManager manager].persistentStoreCoordinator;
            res.parentContext = mainContext;
            //[threadDictionary setObject:res forKey:kThreadManagedContextKey];
        }
        
        return res;
    }
}

//- (void) dealloc
//{
//    DLog(@"Managed Object Context deallocated!");
//}

- (void) saveRecursively {
    
    if (![self hasChanges])
        return;
    
    [self performBlockAndWait:^{
        
        NSError *error = nil;
        BOOL saved = NO;
        
        @try
        {
            [self processPendingChanges];
            saved = [self save:&error];
            
            if (error) {
                DLog(@"error : %@", error);
            }
        }
        @catch(NSException *exception)
        {
            NSLog(@"Unable to perform save: %@", (id)[exception userInfo] ? : (id)[exception reason]);
        }
        @finally
        {
            if (saved) {
                if ([self parentContext]) {
                    [[self parentContext] saveRecursively];
                }
            }
        }
        
    }];
}

@end
