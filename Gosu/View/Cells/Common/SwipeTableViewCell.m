//
//  SwipeTableViewCell.m
//  Gosu
//
//  Created by Dragon on 10/12/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "SwipeTableViewCell.h"
static CGFloat const kIconHorizontalPadding = 10;
static CGFloat const kMaxBounceAmount = 8;

@interface SwipeTableViewCell()
{
    BOOL swipping;
}

@property (nonatomic, strong) UIPanGestureRecognizer *gesture;
@property (nonatomic, assign) CGFloat dragStart;
@property (nonatomic, assign) SwipeType currentSwipe;
@end

@implementation SwipeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        swipping = NO;
    }
    return self;
}

- (SwipeType)swipeType
{
    return self.currentSwipe;
}

- (void) closeSwipe
{
    [UIView animateWithDuration:0.25 delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.cellView.center = CGPointMake(self.contentView.frame.size.width / 2, self.cellView.center.y);
                     } completion:^(BOOL finished) {
                         [self fireSwipeTypeChange:SwipeTypeNone];
                         self.dragStart = CGFLOAT_MIN;
                     }];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self configureCell];
    
    swipping = NO;
}

- (void)fireSwipeTypeChange:(SwipeType)type
{
    if ([self.delegate respondsToSelector:@selector(swipeCell:triggeredSwipeWithType:)])
        [self.delegate swipeCell:self triggeredSwipeWithType:type];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    if (self.hasSwipe)
    {
        self.cellView.center = CGPointMake(self.contentView.frame.size.width / 2, self.cellView.center.y);
        self.currentSwipe = SwipeTypeNone;
        swipping = NO;
    }
}

#pragma mark - Private methods

- (void)configureCell
{
    if (self.hasSwipe)
    {
        self.gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHappened:)];
        self.gesture.delegate = self;
        [self.cellView addGestureRecognizer:self.gesture];
    }
}

- (void)gestureHappened:(UIPanGestureRecognizer *)sender
{
    CGPoint translatedPoint = [sender translationInView:self];
    switch (sender.state)
    {
        case UIGestureRecognizerStatePossible:
            
            break;
        case UIGestureRecognizerStateBegan:
            
            if ([self.delegate respondsToSelector:@selector(swipeCellShouldStartSwipe:)] &&
                [self.delegate swipeCellShouldStartSwipe:self])
            {
                swipping = YES;
                self.dragStart = sender.view.center.x;
            }
            
            break;
        case UIGestureRecognizerStateChanged:
            
            if (!swipping)
                return;
            
            self.cellView.center = CGPointMake(self.dragStart + translatedPoint.x, self.cellView.center.y);
            CGFloat diff = translatedPoint.x;
            
            SwipeType originalSwipe = self.currentSwipe;
            
            if (diff > 0)
            {
                // in short right swipe area
                if (diff <= self.buttonWidth  / 2)
                {
                    self.currentSwipe = SwipeTypeNone;
                }
                else
                {
                    self.currentSwipe = SwipeTypeRight;
                }
            }
            else if (diff < 0)
            {
                // in short right swipe area
                if (diff >= -self.buttonWidth  / 2)
                {
                    self.currentSwipe = SwipeTypeNone;
                }
                else
                {
                    self.currentSwipe = SwipeTypeLeft;
                }
            }
            
            if (originalSwipe != self.currentSwipe)
            {
                if ([self.delegate respondsToSelector:@selector(swipeCell:swipeTypeChangedFrom:to:)])
                    [self.delegate swipeCell:self swipeTypeChangedFrom:originalSwipe to:self.currentSwipe];
            }
            
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            
            if (!swipping)
                return;
            
            if (self.currentSwipe != SwipeTypeNone)
                [self runSwipeAnimationForType:self.currentSwipe];
            else
                [self runBounceAnimationFromPoint:translatedPoint];
            
            swipping = NO;
            
            break;
            
            break;
        case UIGestureRecognizerStateFailed:
            
            break;
    }
}

- (void)runSwipeAnimationForType:(SwipeType)type
{
    CGFloat newViewCenterX = 0;
    
    if (type == SwipeTypeRight)
    {
        newViewCenterX = (self.cellView.frame.size.width / 2);
    }
    else if (type == SwipeTypeLeft)
    {
        newViewCenterX = (self.cellView.frame.size.width / 2) - self.buttonWidth;
    }
    else
    {
        newViewCenterX = self.dragStart;
    }
    
    [UIView animateWithDuration:0.25 delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.cellView.center = CGPointMake(newViewCenterX, self.cellView.center.y);
                     } completion:^(BOOL finished) {
                         [self fireSwipeTypeChange:type];
                         self.dragStart = CGFLOAT_MIN;
                     }];
}

- (void)runBounceAnimationFromPoint:(CGPoint)point
{
    CGFloat diff = point.x;
    CGFloat pct = diff / (self.buttonWidth + (kIconHorizontalPadding * 2));
    CGFloat bouncePoint = pct * kMaxBounceAmount;
    CGFloat bounceTime1 = 0.25;
    CGFloat bounceTime2 = 0.15;
    
    [UIView animateWithDuration:bounceTime1
                     animations:^{
                         self.cellView.center = CGPointMake(self.dragStart - bouncePoint, self.cellView.center.y);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:bounceTime2
                                          animations:^{
                                              self.cellView.center = CGPointMake(self.dragStart, self.cellView.center.y);
                                          } completion:^(BOOL finished) {
                                              
                                          }];
                     }];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
        return YES;
    
    CGPoint translation = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:self];
    return fabs(translation.y) < fabs(translation.x);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return self.gesture.state == UIGestureRecognizerStatePossible;
}

@end
