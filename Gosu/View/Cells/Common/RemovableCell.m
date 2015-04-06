//
//  RemovableCell.m
//  Gosu
//
//  Created by dragon on 6/6/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "RemovableCell.h"

@interface RemovableCell()
{
    CGPoint touchBeginPos;
    CGPoint cardBeginPos;
}
@property (nonatomic) UIPanGestureRecognizer *gesture;

@end

@implementation RemovableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    self.gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onGesture:)];
    self.gesture.delegate = self;
    cardBeginPos = CGPointZero;
    [self addGestureRecognizer:self.gesture];
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    
    if (!CGPointEqualToPoint(cardBeginPos, CGPointZero))
    {
        self.cellView.center = cardBeginPos;
        cardBeginPos = CGPointZero;
    }
        
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark Swipe to delete

- (void)onGesture:(UIPanGestureRecognizer *)gesture
{
    
    switch ([gesture state]) {
        case UIGestureRecognizerStateBegan:
        {
            touchBeginPos = [gesture locationInView:self];
            CGRect frame = [self.cellView superview].frame;
            cardBeginPos = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGPoint cardPos = cardBeginPos;
            CGPoint touchPos = [gesture locationInView:self];
            cardPos.x += (touchPos.x - touchBeginPos.x);
            
            self.cellView.center = cardPos;
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            
            if (self.cellView.center.x >
                cardBeginPos.x + self.cellView.frame.size.width * 0.25 &&
                [gesture velocityInView:self].x > 1) {
                
                [self onSwipeOut:nil];
                
            }
            else
            {
                [UIView animateWithDuration:.25 animations:^{
                    self.cellView.center = cardBeginPos;
                }];
            }
            
        }
            break;
            
        default:
            break;
    }
}

- (void) onSwipeOut:(id)sender
{
    
    if ( [self.delegate respondsToSelector:@selector(shouldRemoveableCellRemoved:)] ) {
        
        if ( [self.delegate shouldRemoveableCellRemoved:self] ) {
            
            CGPoint pt = self.cellView.center;
            pt.x = CGRectGetMaxX(self.cellView.frame) + 200;
            
            [UIView animateWithDuration:.25 animations:^{
                self.cellView.center = pt;
            }];
            
            return;
        }
    }
    
    [UIView animateWithDuration:.25 animations:^{
        self.cellView.center = cardBeginPos;
    }];
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer{
    
    if (gestureRecognizer != self.gesture)
        return NO;
    
    if (!self.swipeToDeleteEnabled)
        return NO;
    
    CGPoint velocity = [gestureRecognizer velocityInView:self];
    if (ABS(velocity.x) >= ABS(velocity.y))
        return YES;
    
    return NO;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return NO;
}

@end
