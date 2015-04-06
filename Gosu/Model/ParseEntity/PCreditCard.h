//
//  PCreditCard.h
//  Gosu
//
//  Created by dragon on 3/28/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Parse/Parse.h>
#import "CardIOCreditCardInfo.h"


FOUNDATION_EXPORT NSString *const kParseCreditCardClassKey;
FOUNDATION_EXPORT NSString *const kParseCreditCardNumberKey;
FOUNDATION_EXPORT NSString *const kParseCreditCardExpiryMonthKey;
FOUNDATION_EXPORT NSString *const kParseCreditCardExpiryYearKey;
FOUNDATION_EXPORT NSString *const kParseCreditCardCCVKey;
FOUNDATION_EXPORT NSString *const kParseCreditCardUserKey;

@interface PCreditCard : PFObject<PFSubclassing>
@property (strong) NSString *cardNumber;
@property (strong) NSString *ccv;
@property (strong) NSString *postalCode;
@property NSInteger expiryMonth;
@property NSInteger expiryYear;
@property (strong) PFUser *user;

- (CardIOCreditCardType)type;
- (NSString *)displayTypeString;
- (UIImage *)cardLogo;
- (NSString *)redactedCardNumber;
@end
