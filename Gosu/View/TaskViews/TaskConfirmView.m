//
//  NewTaskConfirmView.m
//  Gosu
//
//  Created by Dragon on 10/13/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "TaskConfirmView.h"
#import "NSDate+Task.h"
#import "Task+Extra.h"
#import "PTask.h"
#import "FPTouchView.h"

@interface TaskConfirmView()

@property (nonatomic, weak) FPTouchView *touchView;
@end

@implementation TaskConfirmView

+ (instancetype)confirmViewWithParent:(UIView *)parentView data:(PTask *)task
{
    
    TaskConfirmView *res = [[TaskConfirmView alloc] initWithParentView:parentView data:task];
    
    return res;
    
}

- (id) initWithParentView:(UIView *)parentView data:(PTask *)task
{
    
    FPTouchView *coverView = [[FPTouchView alloc] initWithFrame:parentView.bounds];
    
    if ((self = [super initWithParentView:parentView view:coverView])) {
        
        UIView *titleView = [self setupTitleWithTask:task];
        UIView *detailView = [self setupDetailWithTask:task];
        
        CGRect frame = detailView.frame;
        frame.size.height += CGRectGetHeight(titleView.frame);
        detailView.frame = frame;
        
        CGRect topFrame = titleView.frame;
        topFrame.origin.x = (CGRectGetWidth(frame) - CGRectGetWidth(topFrame)) * 0.5;
        topFrame.origin.y = 0;
        titleView.frame = topFrame;
        
        [detailView addSubview:titleView];
        
        detailView.center = CGPointMake(CGRectGetMidX(coverView.frame), CGRectGetMidY(coverView.frame));
        detailView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [coverView addSubview:detailView];
        
        
        __weak TaskConfirmView *wself = self;
        [coverView setTouchedOutsideBlock:^{
            __strong TaskConfirmView *sself = wself;
            
            if (sself)
            {
                [sself.touchView setTouchedOutsideBlock:nil];
                [sself hideWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut completion:nil];
            }
        }];
        
        self.touchView = coverView;
    }
    
    return self;
}

#pragma mark Setup View
- (UIView *) setupTitleWithTask:(PTask *)task
{
    UIView *titleView;
    
    if ([task.type isEqualToString:TASK_TYPE_FLIGHT])
        titleView = [[[NSBundle mainBundle] loadNibNamed:@"TaskConfirmTitle" owner:self options:nil] objectAtIndex:0];
    else
        titleView = [[[NSBundle mainBundle] loadNibNamed:@"TaskConfirmTitle2" owner:self options:nil] objectAtIndex:0];
    
    if ([task.type isEqualToString:TASK_TYPE_FOOD])
    {
        self.lblAction.text = @"FIND ME A";
        self.lblTaskType.text = [task.type2 length] > 0 ? [NSString stringWithFormat:@"%@ Restaurant", [task.type2 capitalizedString]] : @"Restaurant";
        self.lblTaskType.textColor = [Task colorForType:task.type];
        self.lblAT.text = @"IN";
        self.lblTaskTitle.text = task.title;
    }
    else if ([task.type isEqualToString:TASK_TYPE_TRAVEL])
    {
        if ([task.type2 isEqualToString:TASK_TYPE_FLIGHT])
        {
            self.lblTaskType.text = @"FLIGHT";
            self.lblTaskType.textColor = [Task colorForType:task.type];
            self.lblTaskTitle.text = task.title;
        }
        else if ([task.type2 isEqualToString:TASK_TYPE_LIMO])
        {
            self.lblAction.text = @"BOOK ME A";
            self.lblTaskType.text = @"Limo";
            self.lblTaskType.textColor = [Task colorForType:task.type];
            self.lblAT.text = @"FOR";
            
            if ([task.type3 isEqualToString:TASK_TYPE_LIMO_DESTINATION])
                self.lblTaskTitle.text = @"the Route";
            else
                self.lblTaskTitle.text = [NSString stringWithFormat:@"%d Hours", task.hours];
        }
        else if ([task.type2 isEqualToString:TASK_TYPE_RENTAL])
        {
            self.lblAction.text = @"RENT ME A";
            self.lblTaskType.text = task.type3 ? task.type3 : @"Car";
            self.lblTaskType.textColor = [Task colorForType:task.type];
            self.lblAT.text = @"AT";
            self.lblTaskTitle.text = [NSString stringWithFormat:@"%.6f, %.6f", task.location.latitude, task.location.longitude];
        }
        else if ([task.type2 isEqualToString:TASK_TYPE_TAXI])
        {
            self.lblAction.text = @"BOOK ME";
            self.lblTaskType.text = @"Taxi";
            self.lblTaskType.textColor = [Task colorForType:task.type];
            self.lblAT.text = @"AT";
            self.lblTaskTitle.text = [NSString stringWithFormat:@"%.6f, %.6f", task.location.latitude, task.location.longitude];
        }
    }
    else if ([task.type isEqualToString:TASK_TYPE_ACCOMODATION])
    {
        self.lblAction.text = @"FIND ME";
        self.lblTaskType.text = @"Accomodations";
        self.lblTaskType.textColor = [Task colorForType:task.type];
        self.lblAT.text = @"IN";
        self.lblTaskTitle.text = task.title;
    }
    else if ([task.type isEqualToString:TASK_TYPE_GIFT])
    {
        self.lblAction.text = @"FIND ME A";
        self.lblTaskType.text = @"Gift";
        self.lblTaskType.textColor = [Task colorForType:task.type];
        self.lblAT.text = @"FOR";
        self.lblTaskTitle.text = task.title;
    }
    else if ([task.type isEqualToString:TASK_TYPE_ENTERTAINMENT])
    {
        if ([task.type2 isEqualToString:TASK_TYPE_SPORTS] ||
            [task.type2 isEqualToString:TASK_TYPE_NIGHTLIFE])
        {
            self.lblAction.text = @"FIND ME AN";
            self.lblTaskType.text = @"EVENT";
            self.lblTaskType.textColor = [Task colorForType:task.type];
            self.lblAT.text = @"IN";
            self.lblTaskTitle.text = task.title;
        }
        else if ([task.type2 isEqualToString:TASK_TYPE_THEATRE] ||
                 [task.type2 isEqualToString:TASK_TYPE_CONCERTS] ||
                 [task.type2 isEqualToString:TASK_TYPE_MOVIE])
        {
            self.lblAction.text = @"FIND ME";
            self.lblTaskType.text = [NSString stringWithFormat:@"%@ Tickets", [task.type2 capitalizedString]];
            self.lblTaskType.textColor = [Task colorForType:task.type];
            self.lblAT.text = @"IN";
            self.lblTaskTitle.text = task.title;
        }
    }
    
    return titleView;
}

- (UIView *) setupDetailWithTask:(PTask *)task
{
    UIView *detailView;
    
    if ([task.type2 isEqualToString:TASK_TYPE_FLIGHT] ||
        [task.type isEqualToString:TASK_TYPE_ACCOMODATION])
    {
        detailView = [[[NSBundle mainBundle] loadNibNamed:@"TaskConfirmView" owner:self options:nil] objectAtIndex:0];
        
        self.lblStartDate.attributedText = [task.date attributedDateTimeWithSize:12 forTaskType:task.type];
        self.lblEndDate.attributedText = [task.date2 attributedDateTimeWithSize:12 forTaskType:task.type];
        self.lblCost.text = [NSString stringWithFormat:@"$%d - $%d", (int)task.lowerPrice, (int)task.upperPrice];
        
        if ([task.type2 isEqualToString:TASK_TYPE_FLIGHT])
            self.lblPersons.text = [NSString stringWithFormat:@"%d guests", task.numberOfAdults + task.numberOfChildren + task.numberOfInfants];
        else
            self.lblPersons.text = [NSString stringWithFormat:@"%d guests", task.numberOfPersons];
    }
    else if ([task.type isEqualToString:TASK_TYPE_FOOD] ||
             [task.type isEqualToString:TASK_TYPE_ENTERTAINMENT] ||
             [task.type2 isEqualToString:TASK_TYPE_LIMO])
    {
        detailView = [[[NSBundle mainBundle] loadNibNamed:@"TaskConfirmView2" owner:self options:nil] objectAtIndex:0];
        
        if (task.asap)
            self.lblStartDate.text = @"ASAP";
        else
            self.lblStartDate.attributedText = [task.date attributedDateTimeWithSize:12 forTaskType:task.type];
        
        self.lblPersons.text = [NSString stringWithFormat:@"%d guests", task.numberOfPersons];
        
        if (task.priceLevel > 0)
        {
            self.lblCost.text = [@"" stringByPaddingToLength:task.priceLevel withString:@"$" startingAtIndex:0];
        }
        else
        {
            self.lblCost.text = [NSString stringWithFormat:@"$%d - $%d", (int)task.lowerPrice, (int)task.upperPrice];
        }
    }
    else if ([task.type isEqualToString:TASK_TYPE_GIFT])
    {
        detailView = [[[NSBundle mainBundle] loadNibNamed:@"TaskConfirmView3" owner:self options:nil] objectAtIndex:0];
        self.lblCost.text = [NSString stringWithFormat:@"$%d - $%d", (int)task.lowerPrice, (int)task.upperPrice];
    }
    else if ([task.type2 isEqualToString:TASK_TYPE_RENTAL])
    {
        detailView = [[[NSBundle mainBundle] loadNibNamed:@"TaskConfirmView4" owner:self options:nil] objectAtIndex:0];
        self.lblStartDate.attributedText = [task.date attributedDateTimeWithSize:12 forTaskType:task.type];
        self.lblCost.text = [NSString stringWithFormat:@"$%d - $%d", (int)task.lowerPrice, (int)task.upperPrice];
    }
    else if ([task.type2 isEqualToString:TASK_TYPE_TAXI])
    {
        detailView = [[[NSBundle mainBundle] loadNibNamed:@"TaskConfirmView5" owner:self options:nil] objectAtIndex:0];
        self.lblStartDate.attributedText = [task.date attributedDateTimeWithSize:12 forTaskType:task.type];
        self.lblPersons.text = [NSString stringWithFormat:@"%d guests", task.numberOfPersons];
    }
    
    return detailView;
}


#pragma mark Action

- (IBAction)onDone:(id)sender
{
    [self hideWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(taskConfirmView:didDismissWithResult:)])
        {
            [self.delegate taskConfirmView:self didDismissWithResult:YES];
        }
    }];
}

@end
