//
//  BorderView.m
//  Gosu
//
//  Created by dragon on 3/19/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "BorderView.h"

@implementation BorderView
@synthesize borderColor = _borderColor;
@synthesize lineWidth = _lineWidth;

- (void) awakeFromNib
{
    [super awakeFromNib];
    self.borderColor = self.backgroundColor;
    self.lineWidth = 1;
}

- (void) setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    [self setNeedsDisplay];
}

- (void) setBorderColor:(UIColor *)borderColor
{
    if (borderColor)
    {
        _borderColor = borderColor;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    [self drawInContext:UIGraphicsGetCurrentContext()];
}

- (void)drawInContext:(CGContextRef)context
{
    if (self.borderColor && _lineWidth > 0)
    {
        CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
        CGContextSetLineWidth(context, _lineWidth);
        CGContextStrokeRect(context, [self bounds]);
    }
}

@end