//
//  NSDictionary+Profile.m
//  Gosu
//
//  Created by dragon on 6/6/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "NSDictionary+Profile.h"


@implementation NSDictionary (Profile)


- (NSString *)generalProfileDescription {
    
    NSString *result = @"";
    NSDictionary *temp;
    
    switch ([self[@"type"] intValue]) {
            
        case PersonalInfoTypeAddress:
            
            result = self[@"value"];
            
            break;
            
        case PersonalInfoTypeBirthday:
            
            result = [NSString stringWithFormat:@"%@", self[@"value"]];
            
            break;
            
        case PersonalInfoTypePassport: {
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            
            temp = self[@"value"];
            result = [NSString stringWithFormat:@"%@ - Expires on %@",
                      temp[@"number"],
                      [dateFormatter stringFromDate:temp[@"expireDate"]]];
        }
            break;
            
        case PersonalInfoTypeOther:
            
            result = self[@"value"];
            
            break;
            
        default:
            break;
    }
    
    return result;
}

@end
