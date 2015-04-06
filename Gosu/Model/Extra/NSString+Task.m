//
//  NSString+Task.m
//  Gosu
//
//  Created by Dragon on 10/27/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "NSString+Task.h"
#import "Common.h"

@implementation NSString (Task)

- (NSString *)mainType
{
    if ([self isEqualToString:TASK_TYPE_TRAVEL] ||
        [self isEqualToString:TASK_TYPE_FLIGHT] ||
        [self isEqualToString:TASK_TYPE_LIMO] ||
        [self isEqualToString:TASK_TYPE_RENTAL] ||
        [self isEqualToString:TASK_TYPE_TAXI])
        return TASK_TYPE_TRAVEL;
    
    if ([self isEqualToString:TASK_TYPE_FOOD] ||
        [self isEqualToString:TASK_TYPE_FOOD_TAPAS] ||
        [self isEqualToString:TASK_TYPE_FOOD_FUSION] ||
        [self isEqualToString:TASK_TYPE_FOOD_HOMESTYLE] ||
        [self isEqualToString:TASK_TYPE_FOOD_ETHNIC])
        return TASK_TYPE_FOOD;
    
    if ([self isEqualToString:TASK_TYPE_ENTERTAINMENT] ||
        [self isEqualToString:TASK_TYPE_SPORTS] ||
        [self isEqualToString:TASK_TYPE_THEATRE] ||
        [self isEqualToString:TASK_TYPE_CONCERTS] ||
        [self isEqualToString:TASK_TYPE_NIGHTLIFE] ||
        [self isEqualToString:TASK_TYPE_MOVIE])
        return TASK_TYPE_ENTERTAINMENT;
    
    return self;
}

- (NSString *)subType
{
    
    if ([self isEqualToString:TASK_TYPE_TRAVEL] ||
        [self isEqualToString:TASK_TYPE_ENTERTAINMENT] ||
        [self isEqualToString:TASK_TYPE_ACCOMODATION] ||
        [self isEqualToString:TASK_TYPE_GIFT] ||
        [self isEqualToString:TASK_TYPE_FOOD])
        return nil;
    
    return self;
}

- (BOOL)isEqualToTaskType:(NSString *)taskType ignoreSubType:(BOOL)ignoreSubType
{
    NSString *a = self;
    NSString *b = taskType;
    
    if (ignoreSubType)
    {
        a = [a mainType];
        b = [b mainType];
    }
    
    
    return [a isEqualToString:b];
}
@end
