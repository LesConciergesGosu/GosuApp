//
//  NSString+Task.h
//  Gosu
//
//  Created by Dragon on 10/27/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Task)

- (NSString *)mainType;
- (NSString *)subType;
- (BOOL)isEqualToTaskType:(NSString *)taskType ignoreSubType:(BOOL)ignoreSubType;

@end
