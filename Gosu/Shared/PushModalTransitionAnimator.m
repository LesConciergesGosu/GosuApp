//
//  PushModalTransitionAnimator.m
//  Gosu
//
//  Created by Dragon on 10/28/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "PushModalTransitionAnimator.h"

@implementation PushModalTransitionAnimator

// synchronize with the main animation.
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}


// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect bounds = [[transitionContext containerView] bounds];
    
    if (self.presenting)
    {
        [transitionContext.containerView addSubview:toVC.view];
        
        CGRect toStartFrame = bounds;
        CGRect toEndFrame = bounds;
        
        toStartFrame.origin.x += CGRectGetWidth([transitionContext containerView].bounds);
        
        CGRect fromStartFrame = bounds;
        CGRect fromEndFrame = bounds;
        
        fromEndFrame.origin.x -= CGRectGetWidth([transitionContext containerView].bounds) * 0.25;
        
        toVC.view.frame = toStartFrame;
        fromVC.view.frame = fromStartFrame;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:0 animations:^{
            fromVC.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            toVC.view.frame = toEndFrame;
            fromVC.view.frame = fromEndFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    else
    {
        [transitionContext.containerView addSubview:fromVC.view];
        
        CGRect toStartFrame = bounds;
        CGRect toEndFrame = bounds;
        toStartFrame.origin.x -= CGRectGetWidth([transitionContext containerView].bounds) * 0.25;
        
        CGRect fromStartFrame = bounds;
        CGRect fromEndFrame = bounds;
        
        fromEndFrame.origin.x += CGRectGetWidth([transitionContext containerView].bounds);
        
        toVC.view.frame = toStartFrame;
        fromVC.view.frame = fromStartFrame;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:0 animations:^{
            toVC.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            toVC.view.frame = toEndFrame;
            fromVC.view.frame = fromEndFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}

@end
