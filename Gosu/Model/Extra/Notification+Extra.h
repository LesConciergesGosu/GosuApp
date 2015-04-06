//
//  Notification+Extra.h
//  Gosu
//
//  Created by dragon on 6/14/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "Notification.h"
#import "EntityProtocol.h"

@interface Notification (Extra)<EntityProtocol>

- (BOOL) needToAutoMarkRead;
+ (void) markReadNotificationWithId:(NSString *)parseId
                  completionHandler:(GSuccessWithErrorBlock)completion;
@end
