//
//  NSString+Drawing.m
//  Gosu
//
//  Created by Dragon on 10/28/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "NSString+Drawing.h"

@implementation NSString (Drawing)
- (CGSize)sizeWithFont:(UIFont *)font fitToSize:(CGSize)constraintSize
{
    CGSize sizeToFit;
    // Use boundingRectWithSize for iOS 7 and above, sizeWithFont otherwise.
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
        sizeToFit = [self boundingRectWithSize:constraintSize
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName: font}
                                       context:nil].size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
        
        sizeToFit = [self sizeWithFont:font
                     constrainedToSize:constraintSize
                         lineBreakMode:NSLineBreakByWordWrapping];
        
#pragma clang diagnostic pop
    }
#else
    sizeToFit = [self sizeWithFont:font
                 constrainedToSize:constraintSize
                     lineBreakMode:NSLineBreakByWordWrapping];
#endif
    
    return sizeToFit;
}

- (CGSize)sizeWithFont:(UIFont *)font fitToSize:(CGSize)constraintSize lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    CGSize sizeToFit;
    // Use boundingRectWithSize for iOS 7 and above, sizeWithFont otherwise.
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = lineBreakMode;
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
        sizeToFit = [self boundingRectWithSize:constraintSize
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName: font, NSParagraphStyleAttributeName:paragraph}
                                       context:nil].size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
        
        sizeToFit = [self sizeWithFont:font
                     constrainedToSize:constraintSize
                         lineBreakMode:lineBreakMode];
        
#pragma clang diagnostic pop
    }
#else
    sizeToFit = [self sizeWithFont:font
                 constrainedToSize:constraintSize
                     lineBreakMode:lineBreakMode];
#endif
    
    return sizeToFit;
}

@end
