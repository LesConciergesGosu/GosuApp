//
//  DotSpinView.m
//  Gosu
//
//  Created by dragon on 5/5/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "DotSpinView.h"


@interface DotSpinView()
@property (nonatomic, strong) CAShapeLayer *dotLayer;
@end

@implementation DotSpinView
@synthesize dotRadius = _dotRadius;
@synthesize dotColor = _dotColor;
@synthesize dotLayer = _dotLayer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    
    _dotColor = [UIColor redColor];
    _dotRadius = 5;
    
    self.dotLayer = [CAShapeLayer layer];
    _dotLayer.strokeColor = [UIColor clearColor].CGColor;
    _dotLayer.fillColor = _dotColor.CGColor;
    _dotLayer.backgroundColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:_dotLayer];
    _dotLayer.hidden = YES;
}

- (void)setDotRadius:(CGFloat)dotRadius
{
    _dotRadius = dotRadius;
}

- (void)setDotColor:(UIColor *)dotColor
{
    _dotColor = dotColor;
    _dotLayer.fillColor = _dotColor.CGColor;
}

- (void) drawDotLayer
{
    _dotLayer.frame = self.bounds;
    
    CGRect dotFrame = CGRectMake((self.bounds.size.width - _dotRadius) * 0.5,
                                 0,
                                 _dotRadius,
                                 _dotRadius);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:dotFrame];
    _dotLayer.path = path.CGPath;
}

- (void)startAnimationClockWise:(BOOL)clockWise {
    [_dotLayer removeAllAnimations];
    [self drawDotLayer];
    
    _dotLayer.hidden = NO;
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    if (clockWise)
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    else
        rotationAnimation.toValue = [NSNumber numberWithFloat: -M_PI * 2.0];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    [_dotLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopAnimation {
    [_dotLayer removeAllAnimations];
    _dotLayer.hidden = YES;
}



@end
