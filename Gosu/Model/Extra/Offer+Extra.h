//
//  Offer+Extra.h
//  Gosu
//
//  Created by Dragon on 10/12/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "Offer.h"

typedef NS_ENUM(NSInteger, OfferType)
{
    OfferTypeAccomodation = 1,
    OfferTypeFlight,
    OfferTypeFood,
    OfferTypeEntertainment,
    OfferTypeGift
};

@class PTask;
@interface Offer (Extra)

+ (instancetype) objectWithJSONObject:(NSDictionary *)object inContext:(NSManagedObjectContext *)context;
- (void)fillFromJSONObject:(NSDictionary *)json;
- (UIColor *)typeColor;

+ (void)loadMyOffersWithCompletionHandler:(GSuccessWithErrorBlock)completion;
+ (NSArray *) fetchOffers;
+ (NSArray *) fetchOffersFromContext:(NSManagedObjectContext *)context;

- (PTask *)task;
- (void) createNewTaskWithCompletion:(GCreateObjectBlock)completion;
@end
