//
//  GradientView.m
//  Gosu
//
//  Created by Dragon on 10/7/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "GradientView.h"

@implementation GradientView

- (void)setStartColor:(UIColor *)startColor
{
    _startColor = startColor;
    
    [self setNeedsDisplay];
}

- (void) setEndColor:(UIColor *)endColor
{
    _endColor = endColor;
    
    [self setNeedsDisplay];
}

- (void)setVertical:(BOOL)vertical
{
    _vertical = vertical;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGGradientRef gradient;
    CGColorSpaceRef colorSpace;
    
    if (self.startColor && self.endColor)
    {
        CGFloat r1, g1, b1, a1, r2, g2, a2, b2;
        
        [self.startColor getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
        [self.endColor getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
        
        CGFloat components[8]={r1, g1, b1, a1, r2, g2, b2, a2};
        CGFloat locations[2] = {0,1};
        colorSpace = CGColorSpaceCreateDeviceRGB();
        
        gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
    }
    else
    {
        CGFloat components[12]={1, 1, 1, 0.8, 1, 1, 1, 0.8, 1, 1, 1, 0};
        CGFloat locations[3] = {0, 0.35, 1};
        colorSpace = CGColorSpaceCreateDeviceRGB();
        gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 3);
    }
    
    
    CGRect bounds = [self bounds];
    
    CGPoint st;
    CGPoint end;
    
    
    if (self.vertical)
    {
        st = CGPointMake(CGRectGetMidX(bounds), 0);
        end = CGPointMake(CGRectGetMidX(bounds), CGRectGetMaxY(bounds));
    }
    else
    {
        st = CGPointMake(0, CGRectGetMidY(bounds));
        end = CGPointMake(CGRectGetMaxX(bounds), CGRectGetMidY(bounds));
    }
    
    CGContextDrawLinearGradient(context, gradient, st, end, 0);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
}

@end
