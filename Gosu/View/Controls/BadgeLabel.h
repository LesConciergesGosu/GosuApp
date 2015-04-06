//
//  BadgeLabel.h
//  Gosu
//
//  Created by dragon on 7/19/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BadgeLabel : UILabel

@property (nonatomic) CGPoint anchorPoint;
/// Badge value to be display
@property (nonatomic) NSUInteger badgeValue;
/// Padding value for the badge
@property (nonatomic) CGFloat badgePadding;
/// Minimum size badge to small
@property (nonatomic) CGFloat badgeMinSize;
/// In case of numbers, remove the badge when reaching zero
@property BOOL shouldHideBadgeAtZero;
/// Badge has a bounce animation when value changes
@property BOOL shouldAnimateBadge;
@end
