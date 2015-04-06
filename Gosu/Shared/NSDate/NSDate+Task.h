//
//  NSDate+Task.h
//  Gosu
//
//  Created by Dragon on 10/13/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Task)
- (NSAttributedString *)attributedDateTimeWithSize:(CGFloat)size;
- (NSAttributedString *)attributedDateTime2WithSize:(CGFloat)size;

- (NSAttributedString *)attributedDateTimeWithSize:(CGFloat)size forTaskType:(NSString *)taskType;
@end
