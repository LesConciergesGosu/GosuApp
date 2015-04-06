//
//  PTask.m
//  Gosu
//
//  Created by dragon on 3/28/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "PTask.h"
#import "PContract.h"
#import "Task+Extra.h"

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
@dynamic note;
@dynamic voice;
@dynamic activeEmployees;
@dynamic customer;
@dynamic status;
@dynamic card;
@dynamic hours;

@dynamic note2;
@dynamic note3;
@dynamic note4;
@dynamic date;
@dynamic date2;
@dynamic location;
@dynamic location2;
@dynamic type;
@dynamic type2;
@dynamic type3;
@dynamic asap;
@dynamic priceLevel;
@dynamic lowerPrice;
@dynamic upperPrice;
@dynamic numberOfPersons;
@dynamic numberOfAdults;
@dynamic numberOfChildren;
@dynamic numberOfInfants;
@dynamic photoUrl;
@dynamic offerId;
@dynamic address;

@synthesize changed;

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


- (id)objectForKey:(NSString *)key
{
    
    id res = nil;
    
    @try {
        
        res = [super objectForKey:key];
        
    }@catch (NSException *exception) {
        
        res = nil;
        
    } @finally {
        
    }
    
    return res;
}


@end
