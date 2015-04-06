//
//  PCreditCard.m
//  Gosu
//
//  Created by dragon on 3/28/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "PCreditCard.h"
#import "CardHelper.h"
#import <Parse/PFObject+Subclass.h>

NSString *const kParseCreditCardClassKey = @"CreditCard";
NSString *const kParseCreditCardNumberKey = @"cardNumber";
NSString *const kParseCreditCardExpiryMonthKey = @"expiryMonth";
NSString *const kParseCreditCardExpiryYearKey = @"expiryYear";
NSString *const kParseCreditCardCCVKey = @"ccv";
NSString *const kParseCreditCardUserKey = @"user";

@implementation PCreditCard
@dynamic cardNumber;
@dynamic ccv;
@dynamic postalCode;
@dynamic expiryMonth;
@dynamic expiryYear;
@dynamic user;

+ (NSString *)parseClassName {
    return kParseCreditCardClassKey;
}

- (CardIOCreditCardType)type {
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
