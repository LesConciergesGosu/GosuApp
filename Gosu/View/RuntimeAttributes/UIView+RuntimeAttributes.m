//
//  UIView+RuntimeAttributes.m
//  Gosu
//
//  Created by Dragon on 10/12/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "UIView+RuntimeAttributes.h"
#import "AppAppearance.h"

@implementation UIView (RuntimeAttributes)

- (void)setPattern:(NSString *)pattern
{
    if ([[AppAppearance viewPatternName] isEqualToString:pattern])
        self.backgroundColor = [AppAppearance viewPatternColor];
}

- (NSString *)pattern
{
    return nil;
}

- (void)setBorderColor:(UIColor *)borderColor
{
    self.layer.borderColor = borderColor.CGColor;
}

- (UIColor *)borderColor
{
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
}

- (CGFloat)borderWidth
{
    return self.layer.borderWidth;
}

- (void)setShadowColor:(UIColor *)shadowColor
{
    self.layer.shadowColor = shadowColor.CGColor;
}

- (UIColor *)shadowColor
{
    return self.layer.shadowColor ? [UIColor colorWithCGColor:self.layer.shadowColor] : nil;
}

@end
