//
//  DotSpinView.h
//  Gosu
//
//  Created by dragon on 5/5/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DotSpinView : UIView

@property (nonatomic, strong) UIColor *dotColor;
@property (nonatomic) CGFloat dotRadius;

- (void)startAnimationClockWise:(BOOL)clockWise;
- (void)stopAnimation;
@end
