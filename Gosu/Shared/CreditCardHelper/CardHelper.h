//
//  CardHelper.h
//  Gosu
//
//  Created by dragon on 3/21/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CardIO/CardIO.h>

#define CC_LEN_FOR_TYPE		4

@interface CardHelper : NSObject

/*!
 Length of card number for the specificed type.
 
 @param type card type.
 @return
    Return 15 for the American Expression Card. Otherwise, 16.
 */
+ (NSUInteger)lengthOfCardNumberForType:(CardIOCreditCardType)type;

/*!
 Length of formatted card number for the specificed type.
 
 - American Expression card have 2 spaces, \"XXXX XXXXXX XXXXX", 17
 
 - Other cards have 3 spacs, \"XXXX XXXXXX XXXXX", 19
 
 @param type card type.
 @return
    Return 15 for the American Expression Card. Otherwise, 16.
 */
+ (NSUInteger)lengthOfFormattedCardNumberForType:(CardIOCreditCardType)type;

/*!
 Detect the card type from the first 4 digits of the credit card number.
 
 @see http://www.regular-expressions.info/creditcard.html
 */
+ (CardIOCreditCardType)ccType:(NSString *)proposedNumber;

/*!
 Check whether the credit number is valid or not using Regular Expression.
 
 @see http://www.regular-expressions.info/creditcard.html
 */
+ (BOOL)isValidNumber:(NSString *)number;

/*!
 Check whether the credit number is valid or not using Luhn Algorithm.
 
 This should be called after the call of isValidNumber
 
 @see http://www.regular-expressions.info/creditcard.html
 */
+ (BOOL)isLuhnValid:(NSString *)number;

/*!
 Length of CCV/CVV/CID/CIDV for the credit card type.
 @param type:
    card type.
 @return
    Return 4 for the American Expression Card. Otherwise, 3.
 */
+ (int)ccvLengthForType:(CardIOCreditCardType)type;

/*!
 Returns the CCV prompt string for the credit card type.
 
    - American Expressin Card : @"XXXX XXXXXX XXXXX"
    
    - Others : @"XXXX XXXX XXXX XXXX"
 */
+ (NSString *)ccvPromptForType:(CardIOCreditCardType)type;

/**
 Prompt string for the credit card number in a specified type.
 @return
    \"CCV" or \"CIDV"
 */
+ (NSString *)cardNumberPromptForType:(CardIOCreditCardType)type;

/**
 Add space between pairs of numbers if needed.
 @return
    Formatted credit card number string.
 */
+ (NSString *)cardNumberFormatForViewing:(NSString *)enteredNumber;

+ (NSString *)redactedCardNumberFor:(NSString *)cardNumber;

+ (NSString *)redactedCardNumberFor:(NSString *)cardNumber hasSpace:(BOOL)hasSpace;
@end
