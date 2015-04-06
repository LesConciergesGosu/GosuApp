//
//  CurveSlider.m
//  Gosu
//
//  Created by dragon on 3/20/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "CurveSlider.h"

@interface CurveSlider()
{
    CGSize curveSize_;
    CGPoint circleCenter_;
    CGFloat circleRadius_;
    
    CGFloat curveStAngle_;
    CGFloat curveEndAngle_;
    
    CGFloat knobStAngle_;
    CGFloat knobEndAngle_;
    CGFloat knobXStart_;
    CGFloat knobXRange_;
    CGFloat knobAngle_;
    CGRect  knobRect_;
    
    UIPanGestureRecognizer *panGesture_;
}

@property (strong) UIColor *hightlightColor;
@property (strong) UIColor *normalColor;
@end

@implementation CurveSlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (void) initialize
{
    self.hightlightColor = [UIColor colorWithRed:55/255.f green:188/255.f blue:155/255.f alpha:1];
    self.normalColor = [UIColor colorWithWhite:235/255.f alpha:1];
    self.knobSize = 24;
    self.lineWidth = 6;
    _continues = YES;
    [self calculateFrames];
    self.value = 0;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    [self calculateFrames];
    
    //recalculate the knob position
    self.value = self.value;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark Properites

- (void) setValue:(CGFloat)value
{
    _value = value;
    
    knobAngle_ = knobStAngle_ + (knobEndAngle_ - knobStAngle_) * ( 1 - self.value);
    CGFloat knobX = circleCenter_.x + sinf(knobAngle_) * (circleRadius_);
    CGFloat knobY = circleCenter_.y + cosf(knobAngle_) * (circleRadius_);
    CGFloat knobR = self.knobSize * 0.5f - self.lineWidth * 0.5;
    knobRect_ = CGRectMake(knobX - knobR, knobY - knobR, knobR * 2, knobR * 2);
    
    [self setNeedsDisplay];
}

- (CGRect) knobRect
{
    return knobRect_;
}

#pragma mark Touch Event
- (BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self processTouchPoint:[touch locationInView:self] sendEvent:self.continues];
    return YES;
}

- (BOOL) continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self processTouchPoint:[touch locationInView:self] sendEvent:self.continues];
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self processTouchPoint:[touch locationInView:self] sendEvent:YES];
}

- (void) processTouchPoint:(CGPoint)pt sendEvent:(BOOL)sendEvent
{
    pt.x = MAX(knobXStart_, pt.x);
    pt.x = MIN(knobXStart_ + knobXRange_, pt.x);
    
    CGFloat angle = asinf((pt.x - self.bounds.size.width * 0.5) / circleRadius_) + M_PI;
    
    self.value = (angle - knobStAngle_) / (knobEndAngle_ - knobStAngle_);
    
    if (sendEvent)
        [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark Drawing

- (void) calculateFrames
{
    CGSize size = [self bounds].size;
    CGFloat curveWidth = size.width + self.lineWidth * 2;
    CGFloat curveHeight = size.height - self.knobSize * 0.5f - self.lineWidth;
    CGFloat circleRadius = (((curveWidth * 0.5) * (curveWidth * 0.5) / curveHeight) + curveHeight) * 0.5;
    CGFloat circleCenterX = size.width * 0.5;
    CGFloat circleCenterY = self.knobSize * 0.5 + circleRadius;
    
    curveSize_ = CGSizeMake(curveWidth, curveHeight);
    circleCenter_ = CGPointMake(circleCenterX, circleCenterY);
    circleRadius_ = circleRadius;
    
    CGFloat angle = asinf(curveWidth * 0.5 / circleRadius);
    curveEndAngle_ = M_PI + angle;
    curveStAngle_ = M_PI - angle;
    
    knobXRange_ = (curveWidth - self.knobSize * 2 + self.lineWidth * 2);
    knobXStart_ = (size.width - knobXRange_) * 0.5;
    angle = asinf( knobXRange_ * 0.5 / circleRadius);
    knobStAngle_ = M_PI - angle;
    knobEndAngle_ = M_PI + angle;
}

- (void) drawRect:(CGRect)rect
{
    [self drawInContext:UIGraphicsGetCurrentContext()];
}

- (void) drawInContext:(CGContextRef)context
{
    
    if (!self.hightlightColor || !self.normalColor)
    {
        return;
    }
    
    CGFloat curAngle = knobStAngle_ + (knobEndAngle_ - knobStAngle_) * self.value;
    CGContextSaveGState(context); {
        
        CGContextSetBlendMode(context, kCGBlendModeCopy);
        CGContextSetLineWidth(context, self.lineWidth);
        
        [self.normalColor setStroke];
        CGContextAddArc(context, circleCenter_.x, circleCenter_.y, circleRadius_, curAngle + M_PI_2, curveEndAngle_ + M_PI_2, NO);
        CGContextStrokePath(context);
        
        [self.hightlightColor setStroke];
        CGContextAddArc(context, circleCenter_.x, circleCenter_.y, circleRadius_, curveStAngle_ + M_PI_2, curAngle + M_PI_2, NO);
        CGContextStrokePath(context);
        
        [[UIColor clearColor] set];
        CGContextFillEllipseInRect(context,knobRect_);
        [self.hightlightColor setStroke];
        CGContextStrokeEllipseInRect(context, knobRect_);
        
    } CGContextRestoreGState(context);
}

@end
