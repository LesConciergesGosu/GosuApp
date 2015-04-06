//
//  Offer+Extra.m
//  Gosu
//
//  Created by Dragon on 10/12/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "Offer+Extra.h"
#import "Task+Extra.h"
#import "User+Extra.h"
#import "CreditCard+Extra.h"
#import "NSDate+Extra.h"
#import "PCreditCard.h"
#import "PTask.h"
#import "Common.h"
#import <Reachability/Reachability.h>
#import <Parse/Parse.h>
#import "DataManager.h"

@implementation Offer (Extra)



+ (instancetype) objectWithJSONObject:(NSDictionary *)object inContext:(NSManagedObjectContext *)context
{
    if (!object)
        return nil;
    
    NSString *objectId = [object objectForKey:@"id"];
    
    Offer *res = [[DataManager manager] managedObjectWithID:objectId
                                            withEntityName:@"Offer"
                                                 inContext:context];
    
    [res fillFromJSONObject:object];
    
    return res;
}

+ (void)loadMyOffersWithCompletionHandler:(GSuccessWithErrorBlock)completion
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, @"Please check your internet connection.");
        return;
    }
    
    
    User *user = [User currentUser];
    
#ifndef DEBUG
    NSString *userId = user.objectId;
#endif
    
    [[DataManager manager] runInBackgroundWithBlock:^{
        
        NSError *error = nil;
        NSDictionary *result = nil;
        
#ifdef DEBUG
        result = [PFCloud callFunction:@"getAllRecommendations"
                                      withParameters:@{}
                                               error:&error];
#else
        result = [PFCloud callFunction:@"getRecommendations"
                        withParameters:@{@"userId":userId}
                                 error:&error];
        
#endif
        
        
        if (error)
        {
            DLog(@"error : %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(NO, ERROR_TO_STRING(error));
            });
            return;
        }
        
        NSArray *offers = result[@"offers"];
        
        if (![result[@"success"] boolValue])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(NO, @"Unexpected result.");
            });
            return;
        }
        
        
        NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
        [context performBlock:^{
            
            User *currentUser = [User currentUserInContext:context];
            
            NSMutableArray *oldOffers = [NSMutableArray arrayWithArray:[Offer fetchOffersFromContext:context]];
            
            for (NSDictionary *object in offers) {
                Offer * offer = [Offer objectWithJSONObject:object inContext:context];
                
                if (offer.user != currentUser)
                {
                    offer.user = currentUser;
                    offer.createdAt = [NSDate date];
                }
                
                if ([oldOffers containsObject:offer])
                    [oldOffers removeObject:offer];
            }
            
            // we need to remove some offers
            for (Offer *offer in oldOffers)
                [context deleteObject:offer];
            
            // save the context
            [context saveRecursively];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(YES, nil);
            });
        }];
    }];
}

+ (NSArray *) fetchOffers
{
    return [Offer fetchOffersFromContext:[DataManager manager].managedObjectContext];
}

+ (NSArray *) fetchOffersFromContext:(NSManagedObjectContext *)context {
    
    User *user = [User currentUserInContext:context];
    
    if (!user)
        return nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Offer"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@ AND archived == %@", user, @(NO)];
    request.predicate = predicate;
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO]];
    
    return [context executeFetchRequest:request error:nil];
}


- (void)fillFromJSONObject:(NSDictionary *)json
{
    
    NSObject *object;
    NSString *str;
    
    str = json[@"offer"];
    self.offer = str ? [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] : nil;
    
    str = json[@"name"];
    self.name = str ? [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] : nil;
    
    self.zipCode = @([json[@"zipCode"] intValue]);
    self.category = @([json[@"category"] intValue]);
    self.subCat = json[@"subCat"];
    
    if ((object = json[@"price"]))
    {
        if ([object isKindOfClass:[NSNumber class]])
        {
            self.price = @[object];
        }
        else if ([object isKindOfClass:[NSArray class]])
        {
            self.price = [NSArray arrayWithArray:(NSArray *)object];
        }
    }
    else
    {
        self.price = nil;
    }
    
    str = json[@"benefit"];
    self.benefit = str ? [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] : nil;
    
    self.photoUrl = json[@"photoUrl"];
    self.offeredTo = json[@"offeredTo"];
    self.latitude = @([json[@"lat"] doubleValue]);
    self.longitude = @([json[@"lng"] doubleValue]);
    self.address = json[@"address"];
    self.localTimeZone = @([json[@"localTz"] integerValue]);
    
    if ((object = json[@"startDate"]))
        self.startDate = [NSDate dateWithTimeIntervalSince1970:[(id)object doubleValue]];
    else
        self.startDate = nil;
    
    if ((object = json[@"endDate"]))
        self.endDate = [NSDate dateWithTimeIntervalSince1970:[(id)object doubleValue]];
    else
        self.endDate = nil;
    
    if ((object = json[@"startTime"]))
        self.startTime = @([(id)object doubleValue]);
    else
        self.startTime = nil;
    
    if ((object = json[@"endTime"]))
        self.endTime = @([(id)object doubleValue]);
    else
        self.endTime = nil;
    
    self.priority = @([json[@"priority"] intValue]);
    self.romanticOrFamily = @([json[@"romanticOrFamily"] intValue]);
    self.urbanOrAdventure = @([json[@"urbanOrAdventure"] intValue]);
    self.tradOrModern = @([json[@"tradOrModern"] intValue]);
    self.approachOrSophistic = @([json[@"approachOrSophistic"] intValue]);
    self.energeticOrQuiet = @([json[@"energeticOrQuiet"] intValue]);
    self.limitedOrFull = @([json[@"limitedOrFull"] intValue]);
    
    if ((object = json[@"offerOptions"]))
    {
        if ([object isKindOfClass:[NSNumber class]])
        {
            self.offerOptions = @[object];
        }
        else if ([object isKindOfClass:[NSArray class]])
        {
            self.offerOptions = [NSArray arrayWithArray:(NSArray *)object];
        }
    }
    else
    {
        self.offerOptions = nil;
    }
    
    self.destination = @([json[@"destination"] intValue]);
}

- (PTask *)task
{
    PTask *res = [PTask object];
    
    if (self.startDate)
        res.date = self.startDate;
    
    res.offerId = self.objectId;
    res.desc = self.benefit;
    res.title = self.offer;
    res.photoUrl = self.photoUrl ?: nil;
    res.type2 = self.subCat ?: nil;
    res.address = self.address ?: nil;
    
    NSArray *prices = self.price;
    
    if ([prices count] > 0)
        res.priceLevel = [[prices lastObject] intValue];
    
    CreditCard *card = [User currentUser].defaultCard;
    if (card)
        res.card = [PCreditCard objectWithoutDataWithObjectId:card.objectId];
    
    if ([self.latitude doubleValue] != 0 && [self.longitude doubleValue] != 0)
        res.location = [PFGeoPoint geoPointWithLatitude:[self.latitude doubleValue] longitude:[self.longitude doubleValue]];
    
    NSInteger category = [self.category intValue];
    
    if (category == OfferTypeAccomodation)
    {
        res.type = TASK_TYPE_ACCOMODATION;
        res.numberOfPersons = 3;
        res.note = @"";
        
        if (self.startDate && self.endDate)
        {
            res.date = self.startTime ? [self.startDate dateByAddingTimeInterval:[self.startTime doubleValue]] : self.startDate;
            res.date2 = self.endTime ? [self.endDate dateByAddingTimeInterval:[self.endTime doubleValue]] : self.endDate;
        }
        else
        {
            NSDate *date = [[[NSDate date] dateInOneHour] dateByAddingHours:3];
            res.date = [date dateByAddingDays:1];
            res.date2 = [date dateByAddingDays:2];
        }
    }
    else if (category == OfferTypeEntertainment)
    {
        res.type = TASK_TYPE_ENTERTAINMENT;
        res.numberOfPersons = 2;
        res.note = @"";
        
        if (self.startDate && self.endDate)
        {
            res.date = self.startDate;
            res.date2 = self.endDate;
        }
        else
        {
            NSDate *date = [[[NSDate date] dateInOneHour] dateByAddingHours:3];
            res.date = [date dateByAddingDays:1];
            res.date2 = [date dateByAddingDays:2];
        }
    }
    else if (category == OfferTypeFlight)
    {
        res.type = TASK_TYPE_TRAVEL;
        res.type2 = TASK_TYPE_FLIGHT;
        res.numberOfAdults = 1;
        res.numberOfChildren = 2;
        res.numberOfInfants = 1;
        res.note = @"Get me a window seat";
        
        NSDate *date = [[[NSDate date] dateInOneHour] dateByAddingHours:3];
        
        res.date = [date dateByAddingDays:1];
        res.date2 = [date dateByAddingDays:2];
    }
    else if (category == OfferTypeFood)
    {
        res.type = TASK_TYPE_FOOD;
        res.numberOfPersons = 2;
        res.note = @"Get me a window seat";
        
        if (self.startDate && self.endDate)
        {
            res.date = self.startDate;
            res.date2 = self.endDate;
        }
        else
        {
            NSDate *date = [[[NSDate date] dateInOneHour] dateByAddingHours:3];
            res.date = [date dateByAddingDays:1];
            res.date2 = [date dateByAddingDays:2];
        }
    }
    else if (category == OfferTypeGift)
    {
        res.type = TASK_TYPE_GIFT;
        res.note = @"";
        res.date = self.startDate ? self.startDate : [[[[NSDate date] dateInOneHour] dateByAddingHours:3] dateByAddingHours:1];
    }
    
    return res;
}

- (void) createNewTaskWithCompletion:(GCreateObjectBlock)completion
{
    [Task createNewTaskPFObject:[self task] completion:completion];
}

- (UIColor *)typeColor
{
    switch ([self.category intValue]) {
        case OfferTypeAccomodation:
            return [UIColor colorWithRed:41/255.f green:128/255.f blue:185/255.f alpha:1];
        case OfferTypeEntertainment:
            return [UIColor colorWithRed:192/255.f green:57/255.f blue:43/255.f alpha:1];
        case OfferTypeFlight:
            return [UIColor colorWithRed:22/255.f green:160/255.f blue:133/255.f alpha:1];
        case OfferTypeFood:
            return [UIColor colorWithRed:243/255.f green:156/255.f blue:18/255.f alpha:1];
        case OfferTypeGift:
            return [UIColor colorWithRed:142/255.f green:68/255.f blue:173/255.f alpha:1];
        default:
            break;
    }
    
    return [UIColor whiteColor];
}

@end
