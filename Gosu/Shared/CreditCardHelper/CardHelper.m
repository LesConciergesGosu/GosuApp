//
//  CardHelper.m
//  Gosu
//
//  Created by dragon on 3/21/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "CardHelper.h"

// See: http://www.regular-expressions.info/creditcard.html
#define VISA				@"^4[0-9]{15}?"						// VISA 16
#define MC					@"^5[1-5][0-9]{14}$"				// MC 16
#define AMEX_REG			@"^3[47][0-9]{13}$"					// AMEX 15
#define DISCOVER			@"^6(?:011|5[0-9]{2})[0-9]{12}$"	// Discover 16
#define JCB                 @"^(?:2131[1800|35[0-9]3)[0-9]{12}$"	// 3530111333300000

#define VISA_TYPE			@"^4[0-9]{3}?"						// VISA 16
#define MC_TYPE				@"^5[1-5][0-9]{2}$"					// MC 16
#define AMEX_REG_TYPE		@"^3[47][0-9]{2}$"					// AMEX 15
#define DISCOVER_TYPE		@"^6(?:011|5[0-9]{2})$"				// Discover 16
#define JCB_TYPE       @"^(?:2131|1800|35[0-9]3)$"		// DinersClub 14 // 38812345678901

static NSRegularExpression *visaReg;
static NSRegularExpression *mcReg;
static NSRegularExpression *amexReg;
static NSRegularExpression *discoverReg;
static NSRegularExpression *jcbReg;

static NSRegularExpression *visaTypeReg;
static NSRegularExpression *mcTypeReg;
static NSRegularExpression *amexTypeReg;
static NSRegularExpression *discoverTypeReg;
static NSRegularExpression *jcbTypeReg;

@implementation CardHelper

+ (void)initialize
{
	if(self == [CardHelper class]) {
		__autoreleasing NSError *error;
		visaReg				= [NSRegularExpression regularExpressionWithPattern:VISA options:0 error:&error];
		mcReg				= [NSRegularExpression regularExpressionWithPattern:MC options:0 error:&error];
		amexReg				= [NSRegularExpression regularExpressionWithPattern:AMEX_REG options:0 error:&error];
		discoverReg			= [NSRegularExpression regularExpressionWithPattern:DISCOVER options:0 error:&error];
		jcbReg		= [NSRegularExpression regularExpressionWithPattern:JCB options:0 error:&error];
		
		visaTypeReg			= [NSRegularExpression regularExpressionWithPattern:VISA_TYPE options:0 error:&error];
		mcTypeReg			= [NSRegularExpression regularExpressionWithPattern:MC_TYPE options:0 error:&error];
		amexTypeReg			= [NSRegularExpression regularExpressionWithPattern:AMEX_REG_TYPE options:0 error:&error];
		discoverTypeReg		= [NSRegularExpression regularExpressionWithPattern:DISCOVER_TYPE options:0 error:&error];
		jcbTypeReg	= [NSRegularExpression regularExpressionWithPattern:JCB_TYPE options:0 error:&error];
	}
}

+ (NSUInteger)lengthOfCardNumberForType:(CardIOCreditCardType)type
{
	NSUInteger idx;
	
	switch(type) {
        case CardIOCreditCardTypeVisa:
        case CardIOCreditCardTypeMastercard:
        case CardIOCreditCardTypeDiscover:
        case CardIOCreditCardTypeJCB:		// { 4-4-4-4}
            idx = 16;
            break;
        case CardIOCreditCardTypeAmex:			// {4-6-5}
            idx = 15;
            break;
        default:
            idx = 0;
	}
	return idx;
}

+ (NSUInteger)lengthOfFormattedCardNumberForType:(CardIOCreditCardType)type
{
	NSUInteger idx;
	
	switch(type) {
        case CardIOCreditCardTypeVisa:
        case CardIOCreditCardTypeMastercard:
        case CardIOCreditCardTypeDiscover:
        case CardIOCreditCardTypeJCB:// { 4-4-4-4}
            idx = 16 + 3;
            break;
        case CardIOCreditCardTypeAmex:			// {4-6-5}
            idx = 15 + 2;
            break;
        default:
            idx = 0;
	}
	return idx;
}

// http://www.regular-expressions.info/creditcard.html
+ (CardIOCreditCardType)ccType:(NSString *)proposedNumber
{
    if ([proposedNumber length] < CC_LEN_FOR_TYPE)
        return CardIOCreditCardTypeUnrecognized;
    
    NSRange range = NSMakeRange(0, CC_LEN_FOR_TYPE);
    
    if ([amexTypeReg numberOfMatchesInString:proposedNumber options:0 range:range])
        return CardIOCreditCardTypeAmex;
    else if ([discoverTypeReg numberOfMatchesInString:proposedNumber options:0 range:range])
        return CardIOCreditCardTypeDiscover;
    else if ([jcbTypeReg numberOfMatchesInString:proposedNumber options:0 range:range])
        return CardIOCreditCardTypeJCB;
    else if ([mcTypeReg numberOfMatchesInString:proposedNumber options:0 range:range])
        return CardIOCreditCardTypeMastercard;
    else if ([visaTypeReg numberOfMatchesInString:proposedNumber options:0 range:range])
        return CardIOCreditCardTypeVisa;
    
    return CardIOCreditCardTypeUnrecognized;
}

+ (BOOL)isValidNumber:(NSString *)number
{
	NSRegularExpression *reg;
	BOOL ret = NO;
    
    CardIOCreditCardType type = [CardHelper ccType:number];
    
    switch (type) {
        case CardIOCreditCardTypeAmex:
            reg = amexReg;
            break;
        case CardIOCreditCardTypeDiscover:
            reg = discoverReg;
            break;
        case CardIOCreditCardTypeJCB:
            reg = jcbReg;
            break;
        case CardIOCreditCardTypeMastercard:
            reg = mcReg;
            break;
        case CardIOCreditCardTypeVisa:
            reg = visaReg;
            break;
        default:
            break;
    }
    
	if(reg) {
		NSUInteger matches = [reg numberOfMatchesInString:number options:0 range:NSMakeRange(0, [number length])];
		ret = matches == 1 ? YES : NO;
	}
    
	return ret;
}

// See: http://www.brainjar.com/js/validation/default2.asp
+ (BOOL)isLuhnValid:(NSString *)number
{
	NSString *baseNumber = [number stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSUInteger total = 0;
	
	NSUInteger len = [baseNumber length];
	for(NSUInteger i=len; i > 0; ) {
		BOOL odd = (len-i)&1;
		--i;
		unichar c = [baseNumber characterAtIndex:i];
		if(c < '0' || c > '9') continue;
		c -= '0';
		if(odd) c *= 2;
		if(c >= 10) {
			total += 1;
			c -= 10;
		}
		total += c;
	}
    
	return (total%10) == 0 ? YES : NO;
}

+ (int)ccvLengthForType:(CardIOCreditCardType)type
{
    switch(type) {
        case CardIOCreditCardTypeVisa:
        case CardIOCreditCardTypeMastercard:
        case CardIOCreditCardTypeDiscover:
        case CardIOCreditCardTypeJCB: // { 4-4-4-4}
            return 3;
            break;
        case CardIOCreditCardTypeAmex:			// {4-6-5}
            return 4;
            break;
        default:
            break;
	}
    
    return 3;
}

+ (NSString *)ccvPromptForType:(CardIOCreditCardType)type
{
    switch(type) {
        case CardIOCreditCardTypeVisa:
        case CardIOCreditCardTypeMastercard:
        case CardIOCreditCardTypeDiscover:
        case CardIOCreditCardTypeJCB: // { 4-4-4-4}
            return @"CCV";
            break;
        case CardIOCreditCardTypeAmex:			// {4-6-5}
            return @"CIDV";
            break;
        default:
            break;
	}
    
    return @"";
}

+ (NSString *)cardNumberPromptForType:(CardIOCreditCardType)type
{
	NSString *number;
    
	switch(type) {
        case CardIOCreditCardTypeVisa:
        case CardIOCreditCardTypeMastercard:
        case CardIOCreditCardTypeDiscover:
        case CardIOCreditCardTypeJCB: // { 4-4-4-4}
            number = @"XXXX XXXX XXXX XXXX";
            break;
        case CardIOCreditCardTypeAmex:			// {4-6-5}
            number = @"XXXX XXXXXX XXXXX";
            break;
        default:
            break;
	}
	return number;
}

+ (NSString *)cardNumberAsterikPromptForType:(CardIOCreditCardType)type
{
	NSString *number;
    
	switch(type) {
        case CardIOCreditCardTypeVisa:
        case CardIOCreditCardTypeMastercard:
        case CardIOCreditCardTypeDiscover:
        case CardIOCreditCardTypeJCB: // { 4-4-4-4}
            number = @"**** **** **** ****";
            break;
        case CardIOCreditCardTypeAmex:			// {4-6-5}
            number = @"**** ****** *****";
            break;
        default:
            break;
	}
	return number;
}

+ (NSString *)cleanNumber:(NSString *)str
{
	return [str stringByReplacingOccurrencesOfString:@" " withString:@""];
}

+ (NSString *)cardNumberFormatForViewing:(NSString *)enteredNumber
{
	NSString *cleaned = [CardHelper cleanNumber:enteredNumber];
	NSInteger len = [cleaned length];
	
	if(len <= CC_LEN_FOR_TYPE) return cleaned;
    
	NSRange r2; r2.location = NSNotFound;
	NSRange r3; r3.location = NSNotFound;
	NSRange r4; r4.location = NSNotFound;
	NSMutableArray *gaps = [NSMutableArray arrayWithObjects:@"", @"", @"", nil];
    
	NSUInteger segmentLengths[3] = { 0, 0, 0 };
    
	switch([CardHelper ccType:enteredNumber]) {
        case CardIOCreditCardTypeVisa:
        case CardIOCreditCardTypeMastercard:
        case CardIOCreditCardTypeDiscover:
        case CardIOCreditCardTypeJCB: // { 4-4-4-4}
            segmentLengths[0] = 4;
            segmentLengths[1] = 4;
            segmentLengths[2] = 4;
            break;
        case CardIOCreditCardTypeAmex:			// {4-6-5}
            segmentLengths[0] = 6;
            segmentLengths[1] = 5;
            break;
        default:
            return enteredNumber;
	}
    
	len -= CC_LEN_FOR_TYPE;
	NSRange *r[3] = { &r2, &r3, &r4 };
	NSUInteger totalLen = CC_LEN_FOR_TYPE;
	for(NSUInteger idx=0; idx<3; ++idx) {
		NSInteger segLen = segmentLengths[idx];
		if(!segLen) break;
        
		r[idx]->location = totalLen;
		r[idx]->length = len >= segLen ? segLen : len;
		totalLen += segLen;
		len -= segLen;
		[gaps replaceObjectAtIndex:idx withObject:@" "];
		
		if(len <= 0) break;
	}
    
	NSString *segment1 = [enteredNumber substringWithRange:NSMakeRange(0, CC_LEN_FOR_TYPE)];
	NSString *segment2 = r2.location == NSNotFound ? @"" : [enteredNumber substringWithRange:r2];
	NSString *segment3 = r3.location == NSNotFound ? @"" : [enteredNumber substringWithRange:r3];
	NSString *segment4 = r4.location == NSNotFound ? @"" : [enteredNumber substringWithRange:r4];
    
	NSString *ret = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",
                     segment1, [gaps objectAtIndex:0],
                     segment2, [gaps objectAtIndex:1],
                     segment3, [gaps objectAtIndex:2],
                     segment4 ];
    
	return ret;
}

+ (NSString *)redactedCardNumberFor:(NSString *)cardNumber
{
    if ([cardNumber length] > 4)
    {
        NSMutableString *redactedCardNumber = [[NSMutableString alloc] init];
        for (int i = 0; i < [cardNumber length] - 4; i ++)
            [redactedCardNumber appendString:@"x"];
        [redactedCardNumber appendString:[cardNumber substringWithRange:NSMakeRange([cardNumber length] - 4, 4)]];
        
        return redactedCardNumber;
    }
    
    return @"";
}

+ (NSString *)redactedCardNumberFor:(NSString *)cardNumber hasSpace:(BOOL)hasSpace {
    
    if (!hasSpace)
        return [CardHelper redactedCardNumberFor:cardNumber];
    
    if ([cardNumber length] > 4) {
        CardIOCreditCardType ccType = [CardHelper ccType:cardNumber];
        NSString *prompt = [CardHelper cardNumberAsterikPromptForType:ccType];
        
        NSMutableString *redactedCardNumber = [[NSMutableString alloc] initWithString:[prompt substringToIndex:[prompt length] - 4]];
        [redactedCardNumber appendString:[cardNumber substringWithRange:NSMakeRange([cardNumber length] - 4, 4)]];
        
        return redactedCardNumber;
    }
    return @"";
}

@end
