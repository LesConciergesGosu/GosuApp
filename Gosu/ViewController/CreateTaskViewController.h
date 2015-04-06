//
//  CreateTaskViewController.h
//  Gosu
//
//  Created by dragon on 3/20/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskConfirmView.h"
#import "AudioManager.h"
#import <SZTextView.h>

@class PeakCurveSlider;
@class CreditIndicator;
@class DotSpinView;
@class Task;
@interface CreateTaskViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate, TaskConfirmViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UITextField *titleTextField;
@property (nonatomic, weak) IBOutlet SZTextView *descTextView;
@property (nonatomic, weak) IBOutlet UIButton *voiceButton;
@property (nonatomic, weak) IBOutlet DotSpinView *voiceRecordingIndicator;
@property (nonatomic, weak) IBOutlet UIView *attachmentView;
@property (nonatomic, weak) IBOutlet UILabel *voiceAttachedLabel;
@property (nonatomic, weak) IBOutlet UIButton *creditButton;
@property (nonatomic, weak) IBOutlet UIView *creditAmountView;
@property (nonatomic, weak) IBOutlet CreditIndicator *creditIndicator;
@property (nonatomic, weak) IBOutlet UILabel *creditAmountLabel;
@property (nonatomic, weak) IBOutlet UILabel *creditHoursLabel;
@property (nonatomic, weak) IBOutlet UIView *cardAmountView;
@property (nonatomic, weak) IBOutlet UIView *cardAmountLabelView;
@property (nonatomic, weak) IBOutlet UILabel *cardAmountLabel;
@property (nonatomic, weak) IBOutlet PeakCurveSlider *cardAmountSlider;
@property (nonatomic, weak) IBOutlet UILabel *totalAmountLabel;

@property (nonatomic, strong) Task *task;

@end
