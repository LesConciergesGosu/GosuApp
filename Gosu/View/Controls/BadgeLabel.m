//
//  BadgeLabel.m
//  Gosu
//
//  Created by dragon on 7/19/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "BadgeLabel.h"

@implementation BadgeLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initializer];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self initializer];
    }
    return self;
}

- (void)initializer
{
    // Default design initialization
    _badgePadding = 6;
    _badgeMinSize = 8;
    _anchorPoint = CGPointZero;
    _shouldHideBadgeAtZero = YES;
    _shouldAnimateBadge = YES;
    self.textColor          = [UIColor whiteColor];
    self.font               = [UIFont systemFontOfSize:12.0];
    self.textAlignment      = NSTextAlignmentCenter;
    // Avoids badge to be clipped when animating its scale
}

- (UILabel *)duplicateLabel:(UILabel *)labelToCopy
{
    UILabel *duplicateLabel = [[UILabel alloc] initWithFrame:labelToCopy.frame];
    duplicateLabel.text = labelToCopy.text;
    duplicateLabel.font = labelToCopy.font;
    
    return duplicateLabel;
}

- (void)updateBadgeFrame
{
    // When the value changes the badge could need to get bigger
    // Calculate expected size to fit new value
    // Use an intermediate label to get expected size thanks to sizeToFit
    // We don't call sizeToFit on the true label to avoid bad display
    
    
    UILabel *frameLabel = [self duplicateLabel:self];
    [frameLabel sizeToFit];
    
    CGSize expectedLabelSize = frameLabel.frame.size;
    
    // Make sure that for small value, the badge will be big enough
    CGFloat minHeight = expectedLabelSize.height;
    
    // Using a const we make sure the badge respect the minimum size
    minHeight = (minHeight < self.badgeMinSize) ? self.badgeMinSize : expectedLabelSize.height;
    CGFloat minWidth = expectedLabelSize.width;
    CGFloat padding = self.badgePadding;
    
    // Using const we make sure the badge doesn't get too smal
    minWidth = (minWidth < minHeight) ? minHeight : expectedLabelSize.width;
    
    CGSize nSize = CGSizeMake(minWidth + padding, minHeight + padding);
    
    CGRect frame = self.frame;
    CGPoint origin = frame.origin;
    origin.x += (frame.size.width - nSize.width) * self.anchorPoint.x;
    origin.y += (frame.size.height - nSize.height) * self.anchorPoint.y;
    frame.origin = origin;
    frame.size = nSize;
    
    self.frame = frame;
    self.layer.cornerRadius = (minHeight + padding) / 2;
    self.layer.masksToBounds = YES;
}


// Handle the badge changing value
- (void)updateBadgeValueAnimated:(BOOL)animated
{
    // Bounce animation on badge if value changed and if animation authorized
    if (animated && self.shouldAnimateBadge && [self.text intValue] != self.badgeValue) {
        CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [animation setFromValue:[NSNumber numberWithFloat:1.5]];
        [animation setToValue:[NSNumber numberWithFloat:1]];
        [animation setDuration:0.2];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:.4 :1.3 :1 :1]];
        [self.layer addAnimation:animation forKey:@"bounceAnimation"];
    }
    
    // Set the new value
    if (self.badgeValue > 99)
        self.text = @"99+";
    else
        self.text = [NSString stringWithFormat:@"%d", (int)self.badgeValue];
    
    // Animate the size modification if needed
    NSTimeInterval duration = animated ? 0.2 : 0;
    [UIView animateWithDuration:duration animations:^{
        [self updateBadgeFrame];
    }];
}


- (void)removeBadge
{
    // Animate badge removal
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:nil];
}
#pragma mark - Setters


- (void)setBadgeValue:(NSUInteger)badgeValue
{
    // Set new value
    _badgeValue = badgeValue;
    
    // When changing the badge value check if we need to remove the badge
    if (badgeValue == 0 && self.shouldHideBadgeAtZero) {
        [self removeBadge];
    } else if (self.alpha < 1) {
        // Create a new badge because not existing
        if (!self.backgroundColor)
            self.backgroundColor    = [UIColor redColor];
        [self setAlpha:1];
        [self updateBadgeValueAnimated:NO];
    } else {
        [self updateBadgeValueAnimated:YES];
    }
}

- (void)setBadgePadding:(CGFloat)badgePadding
{
    _badgePadding = badgePadding;
    
    [self updateBadgeFrame];
}



- (void)setBadgeMinSize:(CGFloat)badgeMinSize
{
    _badgeMinSize = badgeMinSize;
    
    [self updateBadgeFrame];
}

@end
