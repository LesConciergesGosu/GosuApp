//
//  PeakCurveSlider.h
//  Gosu
//
//  Created by dragon on 3/25/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "CurveSlider.h"

@interface PeakCurveSlider : UIControl
{
@public
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

///value of slider 0 - 1
@property (nonatomic) CGFloat knobSize;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) BOOL continues;
@property (strong) UIColor *hightlightColor;
@property (strong) UIColor *normalColor;

@property (nonatomic) BOOL peak;
@property (nonatomic) int value;

- (CGRect) knobRect;

- (void) setCurrentValue:(int)v;
@end
