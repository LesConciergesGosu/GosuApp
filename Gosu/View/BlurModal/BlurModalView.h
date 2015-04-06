//
//  BlurModalView.h
//  Gosu
//
//  Created by dragon on 3/22/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kBMVBlurDidShowNotification;
extern NSString * const kBMVBlurDidHidewNotification;

typedef NS_ENUM(NSInteger, BlurModalViewAnimation)
{
    BlurModalViewAnimationNone,
    BlurModalViewAnimationNormal,
    BlurModalViewAnimationAlertView
};

@interface BlurModalView : UIView

@property (assign, readonly) BOOL isVisible;

@property (assign) CGFloat animationDuration;
@property (assign) CGFloat animationDelay;
@property (assign) BlurModalViewAnimation presentAnimation;
@property (assign) UIViewAnimationOptions animationOptions;
@property (assign) BOOL dismissButtonRight;
@property (nonatomic, copy) void (^defaultHideBlock)(void);

- (id)initWithViewController:(UIViewController*)viewController view:(UIView*)view;
- (id)initWithParentView:(UIView*)parentView view:(UIView*)view;
- (id)initWithView:(UIView*)view;

- (void)setDismissButton:(UIButton *)dismissButton;

- (void)show;
- (void)showWithDuration:(CGFloat)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options completion:(void (^)(void))completion;

- (void)hide;
- (void)hideWithDuration:(CGFloat)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options completion:(void (^)(void))completion;

-(void)hideCloseButton:(BOOL)hide;
@end