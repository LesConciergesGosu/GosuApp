//
//  CreditCard+Extra.h
//  Gosu
//
//  Created by dragon on 3/31/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "CreditCard.h"
#import "EntityProtocol.h"

@class PCreditCard;
@interface CreditCard (Extra)<EntityProtocol>

/*!
 @return the credit card type.
 
 we get the type from the first 4 digits of credit card number.
 
 @see CardIOCreditCardType
 */
- (NSInteger/*CardIOCreditCardType*/)type;


/*!
 @return String represent the type.
 @see CardIOCreditCardInfo
 */
- (NSString *)displayTypeString;

/*!
 @return UIImage instance for the card logo.
 @see CardIOCreditCardInfo
 */
- (UIImage *)cardLogo;

/*!
 @return xxxxxxxxx4987 (redacted card number)
 @see CardHelper
 */
- (NSString *)redactedCardNumber;
@end
