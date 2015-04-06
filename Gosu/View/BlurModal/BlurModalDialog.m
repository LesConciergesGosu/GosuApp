//
//  BlurModalDialog.m
//  Gosu
//
//  Created by dragon on 3/22/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "BlurModalDialog.h"
#import "UIView+Size.h"
#import "UILabel+AutoHeight.h"

#define DIALOG_WIDTH 250.f

@interface BlurModalDialog ()
@end

#pragma mark - BlurModalDialog

@implementation BlurModalDialog

+ (UIView*)generateModalViewWithTitle:(NSString*)title message:(NSString*)message {
    CGFloat defaultWidth = DIALOG_WIDTH;
    CGRect frame = CGRectMake(0, 0, defaultWidth, 0);
    CGFloat padding = 15.f;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 32, defaultWidth - padding * 2.f, 0)];
    titleLabel.text = title;
    titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
    titleLabel.textColor = [UIColor colorWithRed:33/255.f green:39/255.f blue:47/255.f alpha:1];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel autoHeight];
    titleLabel.top = 32;
    titleLabel.numberOfLines = 0;
    [view addSubview:titleLabel];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 0, defaultWidth - padding * 2.f, 0)];
    messageLabel.text = message;
    messageLabel.numberOfLines = 0;
    messageLabel.font = [UIFont systemFontOfSize:10.f];
    messageLabel.textColor = titleLabel.textColor;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.backgroundColor = [UIColor clearColor];
    [messageLabel autoHeight];
    messageLabel.top = titleLabel.bottom + 10;
    [view addSubview:messageLabel];
    
    view.height = messageLabel.bottom + 80;
    
    UIImageView *bottomBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, view.height - 64, defaultWidth, 64)];
    bottomBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    bottomBar.image = [[UIImage imageNamed:@"dialog_bottom_bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    [view addSubview:bottomBar];
    
    UIImageView *bottomBarButtonArea = [[UIImageView alloc] initWithFrame:CGRectMake((DIALOG_WIDTH - 64) * .5f, view.height - 64, 64, 64)];
    bottomBarButtonArea.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    bottomBarButtonArea.image = [UIImage imageNamed:@"dialog_bottom_bar_center"];
    [view addSubview:bottomBarButtonArea];
    
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:view.bounds];
    bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    bgView.image = [[UIImage imageNamed:@"dialog_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch];
    [view insertSubview:bgView atIndex:0];
    
    view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    
    return view;
}

- (id)initWithTitle:(NSString*)title message:(NSString*)message {
    
    if (self = [self initWithTitle:title message:message fromView:nil]) {
    }
    
    return self;
}

- (id)initWithTitle:(NSString*)title message:(NSString*)message fromView:(UIView *)parentView
{
    UIView *view = [BlurModalDialog generateModalViewWithTitle:title message:message];
    
    if ((self = [self initWithParentView:parentView view:view])) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((DIALOG_WIDTH - 50) * .5f, view.height - 57, 50, 50)];
        [button setBackgroundImage:[UIImage imageNamed:@"btn_round_bg.png"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:@"OK" forState:UIControlStateNormal];
        [button titleLabel].font = [UIFont boldSystemFontOfSize:18.f];
        button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [view addSubview:button];
        
        [self setDismissButton:button];
        [self setPresentAnimation:BlurModalViewAnimationAlertView];
    }
    return self;
}



@end
