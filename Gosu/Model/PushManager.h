//
//  PushManager.h
//  Gosu
//
//  Created by dragon on 4/1/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Notification;
@interface PushManager : NSObject

/**
 Return singletone instance.
 */
+ (PushManager *)manager;

/**
 set device token to PFInstallation
 */
- (void) setDeviceTokenFromData:(NSData *)deviceToken;

/**
 reset the badge number from both local & server
 */
- (void) resetBadgeNumber:(id)sender;

/**
 handle the push notification messages according to the notificatin type.
 */
- (void) handlePushMessage:(NSDictionary *)userInfo
         CompletionHandler:(GSuccessBlock)completion;

- (void) handleNotification:(Notification *)notification;
@end
