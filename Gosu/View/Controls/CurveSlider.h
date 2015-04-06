//
//  CurveSlider.h
//  Gosu
//
//  Created by dragon on 3/20/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurveSlider : UIControl

///value of slider 0 - 1
@property (nonatomic) CGFloat value;
@property (nonatomic) CGFloat knobSize;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) BOOL continues;

- (CGRect) knobRect;
@end
