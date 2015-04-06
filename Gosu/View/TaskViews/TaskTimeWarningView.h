//
//  TaskTimeWarningView.h
//  Gosu
//
//  Created by Dragon on 1/21/15.
//  Copyright (c) 2015 Matt Clemenson. All rights reserved.
//

#import "BlurModalDialog.h"

@class TaskTimeWarningView;
@protocol TaskTimeWarningViewDelegate <NSObject>

@optional
- (void) taskTimeWarningView:(TaskTimeWarningView *)view didDismissWithResult:(BOOL)result;

@end

@interface TaskTimeWarningView : BlurModalDialog

@property (nonatomic, strong) UIView *detailView;
@property (nonatomic, weak) IBOutlet UIImageView *imvIcon;
@property (nonatomic, weak) IBOutlet UILabel *lblTaskType;
@property (nonatomic, weak) IBOutlet UILabel *lblTime;
@property (nonatomic, weak) IBOutlet UILabel *lblDescription;


@property (nonatomic, strong) ObjectBlock doneBlock;
@property (nonatomic, strong) ObjectBlock cancelBlock;

@property (weak) id<TaskTimeWarningViewDelegate> delegate;

+ (instancetype)taskTimeWarningViewWithParent:(UIView *)parentView;

@end
