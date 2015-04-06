//
//  PTask.m
//  Gosu
//
//  Created by dragon on 3/28/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "PTask.h"
#import "Task+Extra.h"
#import "PContract.h"
#import "DataManager.h"
#import <Parse/PFObject+Subclass.h>

NSString *const kParseTaskClassKey = @"Task";

NSString *const kParseTaskTitleKey = @"title";
NSString *const kParseTaskDescriptionKey = @"desc";
NSString *const kParseTaskVoiceKey = @"voice";
NSString *const kParseTaskCardKey = @"card";
NSString *const kParseTaskCardAmountKey = @"cardAmount";
NSString *const kParseTaskCreditsKey = @"credits";
NSString *const kParseTaskHoursKey = @"hours";
NSString *const kParseTaskCustomerKey = @"customer";
NSString *const kParseTaskActiveEmployeesKey = @"activeEmployees";
NSString *const kParseTaskStatusKey = @"status";

@implementation PTask
@dynamic title;
@dynamic desc;
@dynamic voice;

@dynamic activeEmployees;
@dynamic customer;
@dynamic status;

@dynamic card;
@dynamic cardAmount;
@dynamic credits;
@dynamic hours;

+ (NSString *)parseClassName {
    return kParseTaskClassKey;
}

- (PFUser *)mainWorker
{
    
    if ([self.activeEmployees count] > 0) {
        return self.activeEmployees[0];
    }
    
    return nil;
}

- (NSString *)channelName
{
    return [NSString stringWithFormat:@"task_%@", [self objectId]];
}

- (void) fetchIfNeededInBackgroundWithBlock:(PFObjectResultBlock)block {
    
    [super fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        NSManagedObjectContext *context = [DataManager manager].managedObjectContext;
        [Task objectFromParseObject:(PTask *)object inContext:context];
        if ([context hasChanges]) {
            [context save:nil];
        }
        
        block(object, error);
    }];
}





@end
