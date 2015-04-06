//
//  PopoverView.m
//  Gosu
//
//  Created by Dragon on 12/22/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "PopoverView.h"

@implementation PopoverView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = YES;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.clipsToBounds = YES;
        self.layer.masksToBounds = YES;
    }
    
    return self;
}

- (CGPathRef)maskPathForSize:(CGSize)size
{
    
    PopoverArrowDirection direction = self.direction;
    CGFloat w = size.width;
    CGFloat h = size.height;
    CGFloat ah = 8; //is the height of the triangle of the arrow
    CGFloat aw = 16; //is the 1/2 of the base of the arrow
    CGFloat radius = 2;
    CGFloat b = 0; //border width;
    CGRect rect;
    
    if(direction == PopoverArrowDirectionUp)
    {
        
        rect.size.width = w - 2*b;
        rect.size.height = h - ah - 2*b;
        rect.origin.x = b;
        rect.origin.y = ah + b;
    }
    else if(direction == PopoverArrowDirectionDown || direction == PopoverArrowDirectionDefault)
    {
        rect.size.width = w - 2*b;
        rect.size.height = h - ah - 2*b;
        rect.origin.x = b;
        rect.origin.y = b;
    }
    
    
    else if(direction == PopoverArrowDirectionRight)
    {
        rect.size.width = w - ah - 2*b;
        rect.size.height = h - 2*b;
        rect.origin.x = b;
        rect.origin.y = b;
    }
    else
    {
        //Assuming direction == FPPopoverArrowDirectionLeft to suppress static analyzer warnings
        rect.size.width = w - ah - 2*b;
        rect.size.height = h - 2*b;
        rect.origin.x = ah + b;
        rect.origin.y = b;
    }
    
    //the arrow will be near the origin
    CGFloat ax = /*self.relativeOrigin.x*/ - aw; //the start of the arrow when UP or DOWN
    if(ax < aw + b) ax = aw + b;
    else if (ax +2*aw + 2*b> self.bounds.size.width) ax = self.bounds.size.width - 2*aw - 2*b;
    
    CGFloat ay = /*self.relativeOrigin.y*/ - aw; //the start of the arrow when RIGHT or LEFT
    if(ay < aw + b) ay = aw + b;
    else if (ay +2*aw + 2*b > self.bounds.size.height) ay = self.bounds.size.height - 2*aw - 2*b;
    
    
    //ROUNDED RECT
    // arrow UP
    CGRect innerRect = CGRectInset(rect, radius, radius);
    CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
    CGFloat outside_right = rect.origin.x + rect.size.width;
    CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
    CGFloat outside_bottom = rect.origin.y + rect.size.height;
    CGFloat inside_top = innerRect.origin.y;
    CGFloat outside_top = rect.origin.y;
    CGFloat outside_left = rect.origin.x;
    
    
    //drawing the border with arrow
    CGMutablePathRef path = CGPathCreateMutable();
    
    if (direction == PopoverArrowDirectionDown || direction == PopoverArrowDirectionDefault)
    {
        CGPathMoveToPoint(path, NULL, innerRect.origin.x, outside_top);
        
        CGPathAddLineToPoint(path, NULL, inside_right, outside_top);
        CGPathAddArcToPoint(path, NULL, outside_right, outside_top, outside_right, inside_top, radius);
        
        
        CGPathAddLineToPoint(path, NULL, outside_right, inside_bottom);
        CGPathAddArcToPoint(path, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, radius);
        
        CGPathAddLineToPoint(path, NULL, CGRectGetMidX(innerRect) + aw * 0.5, outside_bottom);
        CGPathAddLineToPoint(path, NULL, CGRectGetMidX(innerRect), outside_bottom + ah);
        CGPathAddLineToPoint(path, NULL, CGRectGetMidX(innerRect) - aw * 0.5, outside_bottom);
        
        CGPathAddLineToPoint(path, NULL, innerRect.origin.x, outside_bottom);
        CGPathAddArcToPoint(path, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
        
        
        CGPathAddLineToPoint(path, NULL, outside_left, inside_top);
        CGPathAddArcToPoint(path, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);
    }
    
    
    
    CGPathCloseSubpath(path);
    
    return path;
}

- (CAShapeLayer *)maskLayer
{
    CAShapeLayer *res = (CAShapeLayer *)self.layer.mask;
    
    if (!res)
    {
        res = [[CAShapeLayer alloc] init];
        res.frame = self.bounds;
        self.layer.mask = res;
        
    }
    
    return res;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self maskLayer].frame = self.bounds;
    [[self maskLayer] setPath:[self maskPathForSize:self.bounds.size]];
}

@end
