//
//  TaskTimeWarningView.m
//  Gosu
//
//  Created by Dragon on 1/21/15.
//  Copyright (c) 2015 Matt Clemenson. All rights reserved.
//

#import "TaskTimeWarningView.h"
#import "Task+Extra.h"
#import "FPTouchView.h"

@interface TaskTimeWarningView()

@property (nonatomic, weak) FPTouchView *touchView;
@end

@implementation TaskTimeWarningView

- (void)dealloc
{
    self.doneBlock = nil;
    self.cancelBlock = nil;
}

+ (instancetype)taskTimeWarningViewWithParent:(UIView *)parentView
{
    TaskTimeWarningView *res = [[TaskTimeWarningView alloc] initWithParentView:parentView];
    
    return res;
}

- (id) initWithParentView:(UIView *)parentView
{
    
    FPTouchView *coverView = [[FPTouchView alloc] initWithFrame:parentView.bounds];
    
    if ((self = [super initWithParentView:parentView view:coverView])) {
        
        UIView *detailView = [[[NSBundle mainBundle] loadNibNamed:@"TaskTimeWarningView" owner:self options:nil] objectAtIndex:0];
        detailView.center = CGPointMake(CGRectGetMidX(coverView.frame), CGRectGetMidY(coverView.frame));
        detailView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [coverView addSubview:detailView];
        self.detailView = detailView;
        
        
        __weak TaskTimeWarningView *wself = self;
        [coverView setTouchedOutsideBlock:^{
            __strong TaskTimeWarningView *sself = wself;
            
            if (sself)
            {
                [sself.touchView setTouchedOutsideBlock:nil];
                [sself onCancel:nil];
            }
        }];
        
        self.touchView = coverView;
    }
    
    return self;
}

- (IBAction)onContinue:(id)sender
{
    __weak TaskTimeWarningView *wself = self;
    
    [self hideWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut completion:^{
        
        __strong TaskTimeWarningView *sself = wself;
        
        if (sself && sself.doneBlock)
        {
            sself.doneBlock(sself);
        }
    }];
}

- (IBAction)onCancel:(id)sender
{
    __weak TaskTimeWarningView *wself = self;
    
    [self hideWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut completion:^{
        
        __strong TaskTimeWarningView *sself = wself;
        
        if (sself && sself.cancelBlock)
        {
            sself.cancelBlock(sself);
        }
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
