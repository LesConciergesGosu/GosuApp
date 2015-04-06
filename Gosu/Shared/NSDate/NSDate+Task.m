//
//  NSDate+Task.m
//  Gosu
//
//  Created by Dragon on 10/13/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "NSDate+Task.h"

@implementation NSDate (Task)
- (NSAttributedString *)attributedDateTimeWithSize:(CGFloat)size
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"E MMM dd"];
    NSDateFormatter *timeFormmater = [[NSDateFormatter alloc] init];
    [timeFormmater setDateFormat:@"hh:mm a"];
    
    NSString *date = [[[dateFormatter stringFromDate:self] stringByAppendingString:@"\n"] uppercaseString];
    NSString *time = [timeFormmater stringFromDate:self];
    
    
    NSMutableAttributedString *res = [[NSMutableAttributedString alloc] init];
    NSAttributedString *str;
    
    str = [[NSAttributedString alloc] initWithString:date attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Medium" size:size]}];
    [res appendAttributedString:str];
    
    str = [[NSAttributedString alloc] initWithString:time attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Light" size:size]}];
    [res appendAttributedString:str];
    
    return res;
}

- (NSAttributedString *)attributedDateTime2WithSize:(CGFloat)size
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, hh:mm a"];
    
    NSString *date = [dateFormatter stringFromDate:self];
    
    NSAttributedString *res = [[NSAttributedString alloc] initWithString:date attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Book" size:size]}];
    
    return res;
}

- (NSAttributedString *)attributedDateTimeWithSize:(CGFloat)size forTaskType:(NSString *)taskType
{
    if ([taskType isEqual:TASK_TYPE_ACCOMODATION] ||
        [taskType isEqual:TASK_TYPE_FLIGHT])
    {
        return [self attributedDateTimeWithSize:size];
    }
    else
    {
        return [self attributedDateTime2WithSize:size];
    }
}

@end
