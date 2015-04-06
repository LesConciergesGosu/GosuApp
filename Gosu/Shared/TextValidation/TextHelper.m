//
//  TextHelper.m
//  Gosu
//
//  Created by dragon on 3/20/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "TextHelper.h"

@implementation TextHelper
+ (BOOL)textIsValidEmailFormat:(NSString *)text {
    
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:text];
}
@end
