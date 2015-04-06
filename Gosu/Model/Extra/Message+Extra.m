//
//  Message+Extra.m
//  Gosu
//
//  Created by dragon on 3/31/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "Message+Extra.h"
#import "User+Extra.h"
#import "Task+Extra.h"
#import "PMessage.h"
#import "PTask.h"
#import "DataManager.h"
#import <Reachability/Reachability.h>

@implementation Message (Extra)

+ (instancetype) objectFromParseObject:(PFObject *)object inContext:(NSManagedObjectContext *)context {
    
    if (!object)
        return nil;
    
    PMessage *pMessage = (PMessage *)object;
    Message *res = [[DataManager manager] managedObjectWithID:pMessage.objectId
                                               withEntityName:@"Message"
                                                    inContext:context];
    
    [res fillInFromParseObject:pMessage];
    
    return res;
}

+ (Message *) sendMessage:(NSString *)text
                  forTask:(Task *)task
               fromAuthor:(User *)user
    withCompletionHandler:(GSuccessWithErrorBlock)completion {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    if (status == NotReachable) {
        DLog(@"Message can't be delivered due to your connection!");
        completion(NO, @"Please check your internet connection.");
        return nil;
    }
    
    
    NSDate *sendDate = [NSDate date];
    
    // 1. save draft message in main context, first.
    NSManagedObjectContext *mainContext = [[DataManager manager] managedObjectContext];
    NSEntityDescription *desc = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:mainContext];
    Message *message = [[Message alloc] initWithEntity:desc insertIntoManagedObjectContext:mainContext];
    message.author = [User currentUser];
    message.task = task;
    message.text = text;
    message.type = @(MessageTypeText);
    message.date = sendDate;
    message.draft = @(YES);
    message.createdAt = [NSDate dateWithTimeIntervalSinceReferenceDate:DBL_MAX];
    
    NSOrderedSet *messages = [task messages];
    NSMutableOrderedSet *newMessages = [NSMutableOrderedSet orderedSetWithOrderedSet:messages];
    [newMessages addObject:message];
    task.messages = messages;
    
    [[DataManager manager] saveMainContext];
    
    //3. send messge to the server
    NSManagedObjectID *messageID = [message objectID];
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        // 3.1 - Send parse message to the server.
        PMessage *pMessage = [PMessage object];
        pMessage.author = [PFUser currentUser];
        pMessage.task = [PTask objectWithoutDataWithObjectId:task.objectId];
        pMessage.text = text;
        pMessage.type = MessageTypeText;
        pMessage.date = sendDate;
        
        NSError *error = nil;
        
        if ([pMessage save:&error]) {
            
            NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
            [context performBlock:^{
                Message *message = (Message *)[context objectWithID:messageID];
                message.createdAt = pMessage.createdAt;
                [context saveRecursively];
                
                [message sendPushMessageForCreation];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(YES, nil);
                });
            }];
            
        } else {
            
            // message is not delivered.
            NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
            [context performBlock:^{
                Message *message = (Message *)[context objectWithID:messageID];
                if (message) {
                    message.status = @(MessageStatusNotDelivered);
                    [context saveRecursively];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, ERROR_TO_STRING(error));
                });
            }];
        }
    }];
    
    return message;
}

+ (Message *) sendPhoto:(UIImage *)image withQuality:(CGFloat)compressionQuality forTask:(Task *)task fromAuthor:(User *)user withCompletionHandler:(GSuccessWithErrorBlock)completion {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        DLog(@"Message can't be delivered due to your connection!");
        completion(NO, @"Please check your internet connection.");
        return nil;
    }
    
    NSString *tempFile = generateNewTemporaryFile(@"jpg");
    [UIImageJPEGRepresentation(image, compressionQuality) writeToFile:tempFile atomically:YES];
    
    CGSize imgSize = [image size];
    NSDate *sendDate = [NSDate date];
    
    //1. save draft message in main context, first.
    NSManagedObjectContext *mainContext = [[DataManager manager] managedObjectContext];
    NSEntityDescription *desc = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:mainContext];
    Message *message = [[Message alloc] initWithEntity:desc insertIntoManagedObjectContext:mainContext];
    message.author = [User currentUser];
    message.task = task;
    message.type = @(MessageTypePhoto);
    message.photoWidth = @(imgSize.width);
    message.photoHeight = @(imgSize.height);
    message.date = sendDate;
    message.draft = @(YES);
    message.file = [[NSURL fileURLWithPath:tempFile] absoluteString];
    message.createdAt = [NSDate dateWithTimeIntervalSinceReferenceDate:DBL_MAX];
    
    NSOrderedSet *messages = [task messages];
    NSMutableOrderedSet *newMessages = [NSMutableOrderedSet orderedSetWithOrderedSet:messages];
    [newMessages addObject:message];
    task.messages = messages;
    
    [[DataManager manager] saveMainContext];
    
    NSManagedObjectID *messageID = [message objectID];
    
    // 2. send messge to the server
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        NSError *error = nil;
        // 2.1 - save image file on the server
        PFFile *imageFile = [PFFile fileWithData:UIImageJPEGRepresentation(image, compressionQuality)];
        
        if (![imageFile save:&error]) {
            
            NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
            [context performBlock:^{
                DLog(@"object id :%@", messageID);
                
                Message *message = (Message *)[context objectWithID:messageID];
                if (message) {
                    message.status = @(MessageStatusNotDelivered);
                    [context saveRecursively];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, ERROR_TO_STRING(error));
                });
            }];
            
            return;
        }
        
        // 2.2 - save the image url in the context
        NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
        [context performBlock:^{
            DLog(@"object id :%@", messageID);
            
            Message *message = (Message *)[context objectWithID:messageID];
            if (message) {
                message.file = imageFile.url;
                [context saveRecursively];
            }
        }];
        
        // 2.3 send the message to the server
        PMessage *pMessage = [PMessage object];
        pMessage.author = [PFUser currentUser];
        pMessage.type = MessageTypePhoto;
        pMessage.task = [PTask objectWithoutDataWithObjectId:task.objectId];
        pMessage.photoWidth = (float)imgSize.width;
        pMessage.photoHeight = (float)imgSize.height;
        pMessage.date = sendDate;
        pMessage.file = imageFile;
        
        if ([pMessage save:&error])
        {
            NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
            [context performBlock:^{
                message.createdAt = pMessage.createdAt;
                [context saveRecursively];
                
                [message sendPushMessageForCreation];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(YES, nil);
                });
            }];
        }
        else
        {
            NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
            [context performBlock:^{
                DLog(@"object id :%@", messageID);
                
                Message *message = (Message *)[context objectWithID:messageID];
                if (message) {
                    message.status = @(MessageStatusNotDelivered);
                    [context saveRecursively];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, ERROR_TO_STRING(error));
                });
            }];
        }
    }];
    
    return message;
}


+ (Message *) sendPhoto:(UIImage *)image forTask:(Task *)task fromAuthor:(User *)user withCompletionHandler:(GSuccessWithErrorBlock)completion {
    
    return [Message sendPhoto:image withQuality:1 forTask:task fromAuthor:user withCompletionHandler:completion];
}

+ (Message *) sendVoice:(NSString *)voicePath forTask:(Task *)task fromAuthor:(User *)user withDuration:(NSTimeInterval)duration CompletionHandler:(GSuccessWithErrorBlock)completion {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        DLog(@"Message can't be delivered due to your connection!");
        completion(NO, @"Please check your internet connection.");
        return nil;
    }
    
    NSDate *sendDate = [NSDate date];
    
    //1. save the draft message in main context, first.
    NSManagedObjectContext *mainContext = [[DataManager manager] managedObjectContext];
    NSEntityDescription *desc = [NSEntityDescription entityForName:@"Message"
                                            inManagedObjectContext:mainContext];
    
    Message *message = [[Message alloc] initWithEntity:desc insertIntoManagedObjectContext:mainContext];
    message.author = [User currentUser];
    message.task = task;
    message.type = @(MessageTypeAudio);
    message.voiceDuration = @(duration);
    message.date = sendDate;
    message.draft = @(YES);
    message.file = nil;
    message.createdAt = [NSDate dateWithTimeIntervalSinceReferenceDate:DBL_MAX];
    
    NSOrderedSet *messages = [task messages];
    NSMutableOrderedSet *newMessages = [NSMutableOrderedSet orderedSetWithOrderedSet:messages];
    [newMessages addObject:message];
    task.messages = messages;
    
    [[DataManager manager] saveMainContext];
    
    NSManagedObjectID *messageID = [message objectID];
    
    
    //2. send messge to the server
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        NSError *error = nil;
        
        PFFile *voiceFile = [PFFile fileWithName:[voicePath lastPathComponent] contentsAtPath:voicePath];
        
        if (![voiceFile save:&error]) {
            // message is not delivered.
            NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
            [context performBlock:^{
                Message *message = (Message *)[context objectWithID:messageID];
                if (message) {
                    message.status = @(MessageStatusNotDelivered);
                    [context saveRecursively];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, ERROR_TO_STRING(error));
                });
            }];
            return;
        }
        
        NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
        [context performBlock:^{
            // voice file saved.
            Message *message = (Message *)[context objectWithID:messageID];
            if (message) {
                message.file = voiceFile.url;
                [context saveRecursively];
            }
        }];
        
        PMessage *pMessage = [PMessage object];
        pMessage.author = [PFUser currentUser];
        pMessage.type = MessageTypeAudio;
        pMessage.task = [PTask objectWithoutDataWithObjectId:task.objectId];
        pMessage.voiceDuration = (int)duration;
        pMessage.date = sendDate;
        pMessage.file = voiceFile;
        
        if ([pMessage save:&error]) {
            
            NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
            [context performBlock:^{
                message.createdAt = pMessage.createdAt;
                [context saveRecursively];
                
                [message sendPushMessageForCreation];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(YES, nil);
                });
            }];
        } else {
            // message is not delivered.
            NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
            [context performBlock:^{
                Message *message = (Message *)[context objectWithID:messageID];
                if (message) {
                    message.status = @(MessageStatusNotDelivered);
                    [context saveRecursively];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, ERROR_TO_STRING(error));
                });
            }];
        }
        
    }];
    
    return message;
}

/*!
 We need to send the push notification to others after send a photo/video/text message.
 
 * if I'm a customer, I need to send the push notification to the employees working on the task.
 
 * If I'm an employee, I need to send the push notification to the customer, and the employee I'm working with.
 
 */
- (void) sendPushMessageForCreation {
    
    PFUser *pCustomer = [PFUser objectWithoutDataWithObjectId:[[self task] customer].objectId];
    NSMutableArray *pEmployees = [NSMutableArray array];
    
    User *currentUser = [User currentUserInContext:self.managedObjectContext];
    
    BOOL isCustomer = [currentUser.userType intValue] == UserTypeCustomer;
    
    if (isCustomer) {
        
        for (User *user in [self task].activeEmployees)
            [pEmployees addObject:[PFUser objectWithoutDataWithObjectId:user.objectId]];
        
    } else {
        
        for (User *user in [self task].activeEmployees) {
            
            if (user != currentUser) {
                // :) we don't need to send push notification to self.
                [pEmployees addObject:[PFUser objectWithoutDataWithObjectId:user.objectId]];
            }
        }
        
    }
    
    NSString *taskId = [self task].objectId;
    NSString *senderId = [currentUser objectId];
    
    [[DataManager manager] runInBackgroundWithBlock:^{
        // Send push notifiction.
        NSDictionary *pushData;
        PFQuery *query;
        if (isCustomer) {
            
            // 1. I'm a customer
            
            pushData = @{@"alert":@"A message from your customer is waiting for you!",
                         @"badge":@"Increment",
                         @"content-available":@(1),
                         @"type":@(PushTypeMessage),
                         @"task":taskId,
                         @"sender":senderId};
            
            PFQuery *query = [PFInstallation query];
            [query whereKey:@"user" containedIn:pEmployees];
            
            [PFPush sendPushDataToQuery:query withData:pushData error:nil];
            
        } else {
            
            // 2. I'm an employee
            
            // 2.1 To customer
            
            pushData = @{@"alert":@"A message from your gosu is waiting for you!",
                         @"badge":@"Increment",
                         @"content-available":@(1),
                         @"type":@(PushTypeMessage),
                         @"task":taskId,
                         @"sender":senderId};
            
            query = [PFInstallation query];
            [query whereKey:@"user" equalTo:pCustomer];
            
            [PFPush sendPushDataToQuery:query withData:pushData error:nil];
            
            
            // 2.2 To partner
            pushData = @{@"alert":@"A message from your partner is waiting for you!",
                         @"badge":@"Increment",
                         @"content-available":@(1),
                         @"type":@(PushTypeMessage),
                         @"task":taskId,
                         @"sender":senderId};
            
            query = [PFInstallation query];
            [query whereKey:@"user" containedIn:pEmployees];
            
            [PFPush sendPushDataToQuery:query withData:pushData error:nil];
        }
    }];
}

- (void)fillInFromParseObject:(PMessage *)pMessage {
    
    if ([pMessage isDataAvailable]) {
        
        NSManagedObjectContext *context = self.managedObjectContext;
        
        if ([pMessage.updatedAt isEqualToDate:self.updatedAt])
            return;
        
        if (![pMessage.objectId isEqual:self.objectId])
            self.objectId = pMessage.objectId;
        
        if (!self.author)
            self.author = [User objectFromParseObject:pMessage.author inContext:context];
        
        if (pMessage.type != [self.type intValue])
            self.type = @(pMessage.type);
        
        if (![pMessage.date isEqualToDate:self.date])
            self.date = pMessage.date;
        
        if (![pMessage.createdAt isEqualToDate:self.createdAt])
            self.createdAt = pMessage.createdAt;
        
        if (!self.task) {
            self.task = [[DataManager manager] managedObjectWithID:pMessage.task.objectId withEntityName:@"Task" inContext:context];
        }
        
        if ([self.status intValue] < MessageStatusDelivered)
            self.status = @(MessageStatusDelivered);
        
        switch (pMessage.type) {
                
            case MessageTypeText:
                if (![pMessage.text isEqual:self.text])
                    self.text = pMessage.text;
                break;
                
            case MessageTypePhoto:
                if (![pMessage.file.url isEqual:self.file])
                    self.file = pMessage.file.url;
                
                if (pMessage.photoWidth != [self.photoWidth floatValue])
                    self.photoWidth = @(pMessage.photoWidth);
                
                if (pMessage.photoHeight != [self.photoHeight floatValue])
                    self.photoHeight = @(pMessage.photoHeight);
                break;
                
            case MessageTypeAudio:
                if (![pMessage.file.url isEqual:self.file])
                    self.file = pMessage.file.url;
                
                if (pMessage.voiceDuration != [self.voiceDuration intValue])
                    self.voiceDuration = @(pMessage.voiceDuration);
                break;
                
            case MessageTypeNotification:
                if (![pMessage.text isEqual:self.text])
                    self.text = pMessage.text;
                break;
                
            default:
                break;
        }
        
        self.updatedAt = pMessage.updatedAt;
    }
}

@end
