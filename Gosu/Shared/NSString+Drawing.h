//
//  NSString+Drawing.h
//  Gosu
//
//  Created by Dragon on 10/28/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Drawing)

- (CGSize)sizeWithFont:(UIFont *)font fitToSize:(CGSize)size;
- (CGSize)sizeWithFont:(UIFont *)font fitToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;
@end
