//
//  PeakCurveSlider.m
//  Gosu
//
//  Created by dragon on 3/25/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "PeakCurveSlider.h"

@interface PeakCurveSlider()

// 0 - 1
@property (nonatomic) CGFloat fValue;
@end
@implementation PeakCurveSlider

@synthesize fValue = _fValue;

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
    self.fValue = 0;
    self.value = 0;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    [self calculateFrames];
    
    //recalculate the knob position
    self.fValue = self.fValue;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark Properites

- (void) setCurrentValue:(int)val {
    CGFloat v;
    int r;
    if (val <= 100) {
        r = val / 2;
        v = r * 60;
    } else if (val <= 350) {
        r = (val - 100) / 5;
        v = 3000 + r * 60;
    } else if (val <= 750) {
        r = (val - 350) / 10;
        v = 6000 + r * 75;
    } else if (val <= 1000) {
        r = (val - 750) / 50;
        v = 9000 + r * 200;
    }
    
    self.value = val;
    self.fValue = v / 10000;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void) setFValue:(CGFloat)fValue
{
    _fValue = fValue;
    
    knobAngle_ = knobStAngle_ + (knobEndAngle_ - knobStAngle_) * ( 1 - _fValue);
    CGFloat knobX = circleCenter_.x + sinf(knobAngle_) * (circleRadius_);
    CGFloat knobY = circleCenter_.y + cosf(knobAngle_) * (circleRadius_);
    CGFloat knobR = self.knobSize * 0.5f - self.lineWidth * 0.5;
    knobRect_ = CGRectMake(knobX - knobR, knobY - knobR, knobR * 2, knobR * 2);
    
    [self setNeedsDisplay];
}

- (CGFloat) fValue
{
    return _fValue;
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
    
    CGFloat value = (angle - knobStAngle_) / (knobEndAngle_ - knobStAngle_);
    
    CGFloat v = value * 10000;
    if (v <= 3000) {
        int r = (int)round (v / 60);
        v = r * 60;
        self.value = r * 2;
    } else if (v <= 6000) {
        int r = (int)round ((v - 3000) / 60);
        v = 3000 + r * 60;
        self.value = r * 5 + 100;
    } else if (v <= 9000) {
        int r = (int)round ((v - 6000) / 75);
        v = 6000 + r * 75;
        self.value = 350 + r * 10;
    } else if (v <= 10000) {
        int r = (int) round ((v - 9000) / 200);
        v = 9000 + r * 200;
        self.value = 750 + r * 50;
    }
    
    self.fValue = v / 10000;
    
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
    
    CGFloat curAngle = knobStAngle_ + (knobEndAngle_ - knobStAngle_) * (self.fValue);
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

