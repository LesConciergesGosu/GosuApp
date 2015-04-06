//
//  SeparaterView.m
//  Gosu
//
//  Created by dragon on 3/20/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "SeparaterView.h"

@interface SeparaterView()

@property (nonatomic, strong) UIColor *strokeColor;
@end

@implementation SeparaterView

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.strokeColor = self.backgroundColor;
    self.backgroundColor = [UIColor clearColor];
    _lineWidth = 0.5f;
}

- (void) setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [self drawInContext:UIGraphicsGetCurrentContext()];
}

- (void) drawInContext:(CGContextRef)context
{
    CGRect frame = [self bounds];
    
    CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
    
    if (frame.size.width < frame.size.height) // vertical
    {
        CGFloat x = floorf(frame.size.width - _lineWidth);
        
        CGContextSetLineWidth(context, _lineWidth);
        CGContextMoveToPoint(context, x, 0);
        CGContextAddLineToPoint(context, x, frame.size.height);
    }
    else // horizontal
    {
        CGFloat y = floorf(frame.size.height - _lineWidth);
        
        CGContextSetLineWidth(context, _lineWidth);
        CGContextMoveToPoint(context, 0, y);
        CGContextAddLineToPoint(context, frame.size.width, y);
    }
    CGContextStrokePath(context);
}

@end

@implementation Separater15View

- (void) awakeFromNib
{
    [super awakeFromNib];
    self.lineWidth = 1.5f;
}
@end
