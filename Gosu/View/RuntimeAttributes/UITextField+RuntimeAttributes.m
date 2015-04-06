//
//  UITextField+RuntimeAttributes.m
//  Gosu
//
//  Created by Dragon on 10/12/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "UITextField+RuntimeAttributes.h"

@implementation UITextField (RuntimeAttributes)

- (UIColor *)placeholderColor
{
    return [UIColor clearColor];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName:placeholderColor}];
    
    self.attributedPlaceholder = str;
}

- (NSString *)fontName
{
    return self.font.fontName;
}

- (void)setFontName:(NSString *)fontName
{
    self.font = [UIFont fontWithName:fontName size:self.font.pointSize];
}

- (void)setBorderColor:(UIColor *)borderColor
{
    self.layer.borderColor = borderColor.CGColor;
    self.layer.borderWidth = 1;
}

- (UIColor *)borderColor
{
    return self.layer.borderColor ? [UIColor colorWithCGColor:self.layer.borderColor] : nil;
}

@end
