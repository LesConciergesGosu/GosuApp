//
//  PushManager.m
//  Gosu
//
//  Created by dragon on 4/1/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "PushManager.h"
#import "AppDelegate.h"

#import "MainViewController.h"
#import "TaskMessageViewController.h"
#import "StatusViewController.h"
#import "UIViewController+ViewDeck.h"

#import "CustomAlertView.h"

#import "User+Extra.h"
#import "Task+Extra.h"
#import "Notification+Extra.h"
#import "PTask.h"
#import "DataManager.h"

@implementation PushManager

+ (PushManager *)manager
{
    static dispatch_once_t once;
    static PushManager *sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id) init
{
    self = [super init];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetBadgeNumber:) name:NotificationNotificationListUpdated object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetBadgeNumber:) name:NotificationUpdatedUnreadMessageCounts object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (MainViewController *)rootViewController {
    return [AppDelegate sharedInstance].rootViewController;
}

- (void) resetBadgeNumber:(id)sender{
    
    NSInteger badge = 0;
    
    if ([User currentUser] != nil) {
        badge = [[User currentUser] countOfUnreadNotifications];
        badge += [[User currentUser] countOfTaskHasNewMessages];
    } else
        return;
    
    [[DataManager manager] runBlock:^{
        PFInstallation *installation = [PFInstallation currentInstallation];
        if (installation.badge != badge) {
            installation.badge = badge;
            [installation save];
        }
    } inBackgroundWithIdentifier:QueueInstallation];
}

- (void) setDeviceTokenFromData:(NSData *)deviceToken
{
    [[DataManager manager] runBlock:^{
        NSError *error = nil;
        PFInstallation *installation = [PFInstallation currentInstallation];
        [installation setDeviceTokenFromData:deviceToken];
        
        if (![installation save:&error])
            DLog(@"[Parse] couldn't save the device token with error : %@", error);
    } inBackgroundWithIdentifier:QueueInstallation];
}

- (void) handlePushMessage:(NSDictionary *)userInfo
         CompletionHandler:(GSuccessBlock)completion {
    
    if (![PFUser currentUser]) {
        [PFPush handlePush:userInfo];
        
        if (completion) completion(NO);
        return;
    }
    
    BOOL appInBackground = [UIApplication sharedApplication].applicationState == UIApplicationStateBackground;
    
    // someone may receive the notifcation he/she sent, we just ignore them
    PFUser *me = [PFUser currentUser];
    if ([[me objectId] isEqualToString:userInfo[@"sender"]]) {
        if (completion) completion(YES);
        return;
    }
    
    // process the notifications
    PushType type = [userInfo[@"type"] intValue];
    
    switch (type) {
        case PushTypeMessage:
        {
            UIViewController *topVC = [self.rootViewController topViewController];
            
            NSString *taskId = userInfo[@"task"];
            if (topVC && [topVC isKindOfClass:[TaskMessageViewController class]]) {
                
                TaskMessageViewController *messageVC = (TaskMessageViewController *)topVC;
                if ([[messageVC.task objectId] isEqualToString:taskId]) {
                    
                    [(TaskMessageViewController *)topVC reloadData];
                    if (completion) completion(YES);
                    return;
                }
                
            }
            
            
            Task *task = [[DataManager manager] managedObjectWithID:taskId withEntityName:@"Task"];
            [task refreshCountOfUnreadMessagesWithCompletionHandler:^(BOOL success, NSString *errorDesc) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationUpdatedUnreadMessageCounts object:nil];
                if (completion) completion(success);
            }];
            return;
        }
            break;
        case PushTypeTaskAccepted:
        case PushTypeTaskCreated:
        case PushTypeTaskReviewed:
        {
            UIViewController *centerVC = [self.rootViewController centerController];
            
            if ([[centerVC rootController] isKindOfClass:[StatusViewController class]]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationLoadNewTask object:nil];
            } else {
                [PFPush handlePush:userInfo];
            }
        }
            break;
            
        case PushTypeTaskDelivered:
        {
            if (appInBackground) {
                if (completion) completion(YES);
                return;
            }
            
            if (userInfo[@"task"]) {
                
                PTask *task = [PTask objectWithoutDataWithObjectId:userInfo[@"task"]];
                [task fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    
                    NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
                    
                    Task *task = [Task objectFromParseObject:(PTask *)object inContext:context];
                    [context saveRecursively];
                    
                    NSString *message = [NSString stringWithFormat:@"%@", [userInfo[@"aps"] objectForKey:@"alert"]];
                    
                    CustomAlertView *alert =
                    [[CustomAlertView alloc] initWithTitle:@"Task Finished"
                                                   message:message
                                                  delegate:self
                                         cancelButtonTitle:@"Rate"
                                         otherButtonTitles:nil];
                    alert.data = task;
                    [alert show];
                }];
            } else {
                [PFPush handlePush:userInfo];
            }
            
            break;
        }
        case PushTypeGetReviewed:
        {
            [[User currentUser] refreshProfileWithCompletionHandler:nil];
        }
            break;
        default:
            [PFPush handlePush:userInfo];
            break;
    }
    
    if (userInfo[@"msgid"]) {
        [Notification markReadNotificationWithId:userInfo[@"msgid"] completionHandler:^(BOOL success, NSString *errorDesc) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNotificationListUpdated object:nil];
        }];
    }
    
    if (completion) completion(YES);
}

- (void) handleNotification:(Notification *)notification {
    
    if ([notification.status intValue] != NotificationStatusRead) {
        
        if ([notification.type intValue] == PushTypeTaskDelivered) {
            [self.rootViewController openTaskReviewModalForTask:notification.task];
        }
        
        [Notification markReadNotificationWithId:notification.objectId completionHandler:^(BOOL success, NSString *errorDesc) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNotificationListUpdated object:nil];
        }];
    }
}

// Task Delivered Mesage -
// Would you like to rate your experience now?
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView isKindOfClass:[CustomAlertView class]]) {
        [self.rootViewController openTaskReviewModalForTask:[(CustomAlertView *)alertView data]];
    }
}

@end
