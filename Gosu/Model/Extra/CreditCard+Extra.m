//
//  CreditCard+Extra.m
//  Gosu
//
//  Created by dragon on 3/31/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "CreditCard+Extra.h"
#import "PCreditCard.h"
#import "CardHelper.h"

#import "DataManager.h"

@implementation CreditCard (Extra)

+ (instancetype) objectFromParseObject:(id)object inContext:(NSManagedObjectContext *)context {
    
    if (!object)
        return nil;
    
    PCreditCard *pCard = (PCreditCard *)object;
    CreditCard *card = [[DataManager manager] managedObjectWithID:[pCard objectId]
                                                   withEntityName:@"CreditCard"
                                                        inContext:context];
    
    [card fillInFromParseObject:pCard];
    
    return card;
}

- (void) fillInFromParseObject:(PCreditCard *)pCard {
    
    if ([pCard isDataAvailable]) {
        
        if ([pCard.updatedAt isEqualToDate:self.updatedAt])
            return;
        
        // credit card number
        if (![pCard.cardNumber isEqual:self.cardNumber])
            self.cardNumber = pCard.cardNumber;
        
        // CCV/CSC/CID number
        if (![pCard.ccv isEqual:self.ccv])
            self.ccv = pCard.ccv;
        
        // card expiry month
        if (pCard.expiryMonth != [self.expiryMonth intValue])
            self.expiryMonth = @(pCard.expiryMonth);
        
        // card expiry year
        if (pCard.expiryYear != [self.expiryYear intValue])
            self.expiryYear = @(pCard.expiryYear);
        
        if (pCard.postalCode && ![pCard.postalCode isEqualToString:self.postalCode])
            self.postalCode = pCard.postalCode;
        
        self.updatedAt = pCard.updatedAt;
    }
}

- (NSInteger/*CardIOCreditCardType*/)type {
    return [CardHelper ccType:self.cardNumber];
}

- (NSString *)displayTypeString {
    return [CardIOCreditCardInfo displayStringForCardType:[self type] usingLanguageOrLocale:@"en"];
}

- (UIImage *)cardLogo {
    return [CardIOCreditCardInfo logoForCardType:[self type]];
}

- (NSString *)redactedCardNumber {
    return [CardHelper redactedCardNumberFor:self.cardNumber];
}

@end
