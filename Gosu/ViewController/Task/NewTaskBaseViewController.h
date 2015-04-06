//
//  NewTaskBaseViewController.h
//  Gosu
//
//  Created by Dragon on 10/12/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class NewTaskBaseViewController;
@protocol NewTaskItemDelegate <NSObject>

@required
- (void)newTaskItemController:(NewTaskBaseViewController *)vc didFinishWithResult:(id)result;

@end

@class NMRangeSlider;
@class DatePicker;
@class CreditCard;
@class DotSpinView;
@class PTask;
@interface NewTaskBaseViewController : UIViewController

@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *colorViews;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *contentView;
// Common Person Slider
@property (nonatomic, strong) IBOutlet NMRangeSlider *personSlider;
@property (nonatomic, strong) IBOutlet UILabel *numberOfPersonsLabel;

// Date Buttons
@property (nonatomic, strong) IBOutlet UIButton *btnStartDate;
@property (nonatomic, strong) IBOutlet UIButton *btnEndDate;

// Location Buttons;
@property (nonatomic, strong) IBOutlet UIButton *btnStartLocation;
@property (nonatomic, strong) IBOutlet UIButton *btnEndLocation;

// Price Level Slider
@property (nonatomic, strong) IBOutlet NMRangeSlider *priceLevelSlider;

// Voice Recorder
@property (nonatomic, weak) IBOutlet UIButton *voiceButton;
@property (nonatomic, weak) IBOutlet DotSpinView *voiceRecordingIndicator;

// Common Price Range Slider
@property (nonatomic, strong) IBOutlet NMRangeSlider *priceRangeSlider;
@property (nonatomic, strong) IBOutlet UILabel *lowerPriceLabel;
@property (nonatomic, strong) IBOutlet UILabel *upperPriceLabel;
@property (nonatomic, strong) IBOutlet UILabel *creditCardLabel;
@property (nonatomic, strong) IBOutlet UITextField *txtNote;
@property (nonatomic, strong) IBOutlet UIToolbar *accessoryBar;
@property (nonatomic, strong) NSString *viewTitle;
@property (nonatomic, strong) DatePicker *datePicker;
@property (nonatomic, strong) CreditCard *creditCard;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic) CLLocationCoordinate2D startLocation;
@property (nonatomic) CLLocationCoordinate2D endLocation;


#pragma mark Public Properties

@property (nonatomic, strong) NSDate *minimumDate;
@property (nonatomic, strong) NSDate *maximumDate;

@property (nonatomic, strong) NSString *taskType;
@property (nonatomic, strong) NSString *subTaskType;
@property (nonatomic) NSInteger taskIndex;
@property (nonatomic, weak) PTask *initialData;
@property (nonatomic, weak) id<NewTaskItemDelegate> delegate;

@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;

+ (id)viewControllerWithPTask:(PTask *)task;
+ (id)viewControllerWithType:(NSString *)taskType subType:(NSString *)subType;


#pragma mark Methods can be overriden
- (IBAction)onBack:(id)sender;
- (IBAction)onDone:(id)sender;
- (IBAction)onAccessoryDone:(id)sender;
- (void)resignAllTextInputs;
- (CGFloat)priceMinimum;
- (CGFloat)priceMaximum;
- (void)initContentWithPTask:(PTask *)task;
- (id/*PTask**/)inputData;
- (NSString *)errorMessageForInvalidInputs;
- (void)voiceRecognizer:(id)recognizer recognizedText:(NSString *)text;
@end
