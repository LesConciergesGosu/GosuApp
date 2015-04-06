//
//  CreditIndicator.m
//  Gosu
//
//  Created by dragon on 3/30/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "CreditIndicator.h"

@interface CreditIndicator()

@end

@implementation CreditIndicator
@synthesize borderColor = _borderColor;
@synthesize fillColor = _fillColor;
@synthesize borderWidth = _borderWidth;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initDefaults];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initDefaults];
    }
    return self;
}

- (void) initDefaults {
    _borderColor = [UIColor colorWithRed:157/255.f green:159/255.f blue:163/255.f alpha:1];
    _fillColor = [UIColor colorWithRed:157/255.f green:159/255.f blue:163/255.f alpha:1];
    _borderWidth = 1;
}

- (void) setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    [self setNeedsDisplay];
}

- (void) setFillColor:(UIColor *)fillColor
{
    _fillColor = fillColor;
    [self setNeedsDisplay];
}

- (void) setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    [self setNeedsDisplay];
}

- (void) setPercent:(CGFloat)percent
{
    _percent = percent;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [self drawInContext:UIGraphicsGetCurrentContext()];
}

- (void) drawInContext:(CGContextRef)context
{
    CGRect ovalFrame = CGRectInset(self.bounds, self.borderWidth * 0.5, self.borderWidth * 0.5);
    CGRect clipFrame = CGRectMake(ovalFrame.origin.x, ovalFrame.origin.y + self.bounds.size.height * (1 - self.percent), self.bounds.size.width, self.bounds.size.height * self.percent);
    if (self.fillColor)
        CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
    if (self.borderColor)
        CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
    CGContextSetLineWidth(context, self.borderWidth);
    CGContextSaveGState(context); {
        CGContextClipToRect(context, clipFrame);
        CGContextFillEllipseInRect(context, ovalFrame);
    } CGContextRestoreGState(context);
    CGContextStrokeEllipseInRect(context, ovalFrame);
}

@end
