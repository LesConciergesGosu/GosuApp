//
//  NewTaskConfirmView.h
//  Gosu
//
//  Created by Dragon on 10/13/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "BlurModalDialog.h"

@class TaskConfirmView;
@protocol TaskConfirmViewDelegate <NSObject>

@optional
- (void) taskConfirmView:(TaskConfirmView *)view didDismissWithResult:(BOOL)result;

@end

@class PTask;
@interface TaskConfirmView : BlurModalDialog

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *lblTaskType;
@property (nonatomic, strong) IBOutlet UILabel *lblTaskTitle;

@property (nonatomic, strong) IBOutlet UILabel *lblAction;
@property (nonatomic, strong) IBOutlet UILabel *lblAT;

@property (nonatomic, strong) IBOutlet UILabel *lblStartDate;
@property (nonatomic, strong) IBOutlet UILabel *lblEndDate;
@property (nonatomic, strong) IBOutlet UILabel *lblPersons;
@property (nonatomic, strong) IBOutlet UILabel *lblCost;
@property (nonatomic, strong) IBOutlet UIView *contentView;

@property (weak) id<TaskConfirmViewDelegate> delegate;

+ (instancetype)confirmViewWithParent:(UIView *)parentView data:(PTask *)task;
@end
