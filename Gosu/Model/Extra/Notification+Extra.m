//
//  Notification+Extra.m
//  Gosu
//
//  Created by dragon on 6/14/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "Notification+Extra.h"
#import "Task+Extra.h"
#import "User+Extra.h"
#import "PNotification.h"
#import "PTask.h"
#import "DataManager.h"

@implementation Notification (Extra)

+ (instancetype) objectFromParseObject:(PFObject *)object inContext:(NSManagedObjectContext *)context
{
    if (!object)
        return nil;
    
    PNotification *pNotification = (PNotification *)object;
    Notification *notification = [[DataManager manager] managedObjectWithID:[pNotification objectId]
                                                         withEntityName:@"Notification"
                                                              inContext:context];
    
    
    [notification fillInFromParseObject:pNotification];
    
    return notification;
}

- (void) fillInFromParseObject:(PNotification *)pNotification {
    
    if ([pNotification isDataAvailable]) {
        
        NSManagedObjectContext *context = self.managedObjectContext;
        
        if ([pNotification.updatedAt isEqualToDate:self.updatedAt])
            return;
        
        self.message = pNotification.message;
        self.status = @(pNotification.status);
        self.type = @(pNotification.type);
        
        if (pNotification.task)
            self.task = [Task objectFromParseObject:pNotification.task inContext:context];
        else
            self.task = nil;
        
        if (pNotification.from)
            self.from = [User objectFromParseObject:pNotification.from inContext:context];
        else
            self.from = nil;
        
        
        if (pNotification.to)
            self.to = [User objectFromParseObject:pNotification.to inContext:context];
        else
            self.to = nil;
        
        self.createdAt = pNotification.createdAt;
        self.updatedAt = pNotification.updatedAt;
    }
}



+ (void) markReadNotificationWithId:(NSString *)parseId
                  completionHandler:(GSuccessWithErrorBlock)completion;
{
    NSString *objectId = parseId;
    
    [[DataManager manager] runBlock:^{
        
        NSError *error = nil;
        
        PNotification *pNotify = [PNotification objectWithoutDataWithObjectId:objectId];
        [pNotify refresh:&error];
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, ERROR_TO_STRING(error));
            });
            return;
        }
        
        error = nil;
        
        pNotify.status = NotificationStatusRead;
        [pNotify save:&error];
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, ERROR_TO_STRING(error));
            });
            return;
        }
        
        NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
        [context performBlock:^{
            
            [Notification objectFromParseObject:pNotify inContext:context];
            
            if ([context hasChanges]) {
                [context saveRecursively];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES, nil);
            });
            
        }];
        
    } inBackgroundWithIdentifier:QueueNotificationList];
    
}

- (BOOL) needToAutoMarkRead
{
    BOOL res = YES;
    
    switch ([self.type intValue]) {
            
        case PushTypeTaskDelivered:
            res = NO;
            break;
            
        default:
            break;
    }
    
    return res;
}

@end
