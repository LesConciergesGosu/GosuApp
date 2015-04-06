//
//  NewTaskBaseViewController.m
//  Gosu
//
//  Created by Dragon on 10/12/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "NewTaskBaseViewController.h"
#import "UIViewController+ViewDeck.h"
#import "NMRangeSlider+RuntimeAttributes.h"
#import "NewTaskFlightViewController.h"
#import "NewTaskFoodViewController.h"
#import "NewTaskLimoViewController.h"
#import "NewTaskRentalViewController.h"
#import "NewTaskGiftViewController.h"
#import "NewTaskEntertainmentViewController.h"
#import "AppDelegate.h"
#import "LocationPicker.h"
#import "TaskConfirmView.h"
#import "DatePicker.h"
#import "SVProgressHUD.h"

#import "DataManager.h"

#import "PFUser+Extra.h"
#import "PTask.h"
#import "PCreditCard.h"

#import "CreditCard+Extra.h"
#import "Task+Extra.h"
#import "User+Extra.h"

#import "AppAppearance.h"
#import "CardHelper.h"
#import "NSDate+Extra.h"
#import "NSDate+Task.h"
#import "DotSpinView.h"

#import <TPKeyboardAvoiding/UIScrollView+TPKeyboardAvoidingAdditions.h>
#import <Parse/Parse.h>
#import <SpeechKit/SpeechKit.h>
#import "CardInputViewController.h"

@interface NewTaskBaseViewController ()<UIGestureRecognizerDelegate, UITextFieldDelegate, TaskConfirmViewDelegate, UIAlertViewDelegate, SKRecognizerDelegate, LocationPickerDelegate>
{
    
    VoiceRecordingState voiceRecordingState;
}
@property (nonatomic, strong) NSTimer *speechTimer;
@property (nonatomic, strong) NSDate *speechStartTime;
@property (nonatomic, strong) SKRecognizer *speechRecognizer;
@end

@implementation NewTaskBaseViewController
@synthesize datePicker = _datePicker;

+ (id)viewControllerWithType:(NSString *)taskType subType:(NSString *)subType
{
    
    NewTaskBaseViewController *res = nil;
    
    if ([taskType isEqualToString:TASK_TYPE_ACCOMODATION])
        res = [[NewTaskFlightViewController alloc] initWithNibName:@"NewTaskAccomodation" bundle:nil];
    else if ([taskType isEqualToString:TASK_TYPE_TRAVEL])
    {
        if ([subType isEqualToString:TASK_TYPE_FLIGHT])
            res = [[NewTaskFlightViewController alloc] initWithNibName:@"NewTaskFlight" bundle:nil];
        else if ([subType isEqual:TASK_TYPE_LIMO])
            res = [[NewTaskLimoViewController alloc] initWithNibName:@"NewTaskLimo" bundle:nil];
        else if ([subType isEqual:TASK_TYPE_RENTAL])
            res = [[NewTaskRentalViewController alloc] initWithNibName:@"NewTaskRental" bundle:nil];
        else if ([subType isEqual:TASK_TYPE_TAXI])
            res = [[NewTaskRentalViewController alloc] initWithNibName:@"NewTaskTaxi" bundle:nil];
            
    }
    else if ([taskType isEqualToString:TASK_TYPE_FOOD])
    {
        res = [[NewTaskFoodViewController alloc] initWithNibName:@"NewTaskFood" bundle:nil];
    }
    else if ([taskType isEqual:TASK_TYPE_GIFT])
    {
        res = [[NewTaskGiftViewController alloc] initWithNibName:@"NewTaskGift" bundle:nil];
    }
    else
    {
        res = [[NewTaskEntertainmentViewController alloc] initWithNibName:@"NewTaskEntertainment" bundle:nil];
    }
    
    if (res)
    {
        res.taskType = taskType;
        res.subTaskType = subType;
    }
    
    return res;
}

+ (id)viewControllerWithPTask:(PTask *)task
{
    NewTaskBaseViewController *res = nil;
    
    res = [NewTaskBaseViewController viewControllerWithType:task.type subType:task.type2];
    res.initialData = task;
    
    return res;
}

- (void)dealloc
{
    self.datePicker = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.viewTitle = [[Task commonTitleForType:self.taskType subType:self.subTaskType] uppercaseString];
    self.title = self.viewTitle;
    
    UIColor *typeColor = [Task colorForType:self.taskType];
    self.view.backgroundColor = typeColor;
    for (UIView *colorView in self.colorViews)
        colorView.backgroundColor = typeColor;
    
    self.navigationItem.hidesBackButton = YES;
    
    voiceRecordingState = VR_IDLE;
    self.startDate = self.endDate = nil;
    self.creditCard = [[User currentUser] defaultCard];
    [self updateCreditCard];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewCardAdded:) name:NotificationCardAdded object:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.initialData)
        [self initContentWithPTask:self.initialData];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    self.scrollView.contentSize = [self.scrollView TPKeyboardAvoiding_calculatedContentSizeFromSubviewFrames];
    
    if ([self.navigationController deckController])
        [[self.navigationController deckController] setPanningGestureDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.navigationController deckController] && [self.navigationController deckController].panningGestureDelegate == self)
        [[self.navigationController deckController] setPanningGestureDelegate:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Navigation Bar

- (void)setRightBarButtonItem:(UIBarButtonItem *)item
{
    self.navigationItem.rightBarButtonItem = item;
}

- (UIBarButtonItem *)rightBarButtonItem
{
    return self.navigationItem.rightBarButtonItem;
}

- (void)setLeftBarButtonItem:(UIBarButtonItem *)item
{
    self.navigationItem.leftBarButtonItem = item;
}

- (UIBarButtonItem *)leftBarButtonItem
{
    return self.navigationItem.leftBarButtonItem;
}

#pragma mark Privates
- (void)updateCreditCard
{
    if (self.creditCard)
    {
        NSString *text;
        
        if ([self.creditCard.cardNumber length] > 4)
        {
            NSString *cardNumber = self.creditCard.cardNumber;
            text = [NSString stringWithFormat:@"PERSONAL   **** %@", [cardNumber substringWithRange:NSMakeRange([cardNumber length] - 4, 4)]];
        }
        else
        {
            text = @"";
        }
        
        self.creditCardLabel.text = text;
    }
    else
    {
        self.creditCardLabel.text = @"";
    }
}

#pragma mark Properties
- (DatePicker *)datePicker
{
    if (!_datePicker)
        _datePicker = [DatePicker datePicker];
    
    return _datePicker;
}

- (CGFloat)priceMinimum
{
    return 100;
}

- (CGFloat)priceMaximum
{
    return 2500;
}

- (NSInteger)personsMinimum
{
    return 1;
}

- (NSInteger)personsMaximum
{
    return 10;
}



- (void)initContentWithPTask:(PTask *)task
{
    CGFloat minPrice = [self priceMinimum];
    CGFloat maxPrice = [self priceMaximum];
    
    if (task.date) {
        self.startDate = task.date;
        [self.btnStartDate setAttributedTitle:[self.startDate attributedDateTimeWithSize:15 forTaskType:self.taskType] forState:UIControlStateNormal];
    }
    
    self.taskType = task.type;
    self.subTaskType = task.type2;
    self.txtNote.text = task.note;
    
    if (self.priceLevelSlider) {
        self.priceRangeSlider.upperValue = (task.lowerPrice - minPrice) / (maxPrice - minPrice);
        self.priceRangeSlider.lowerValue = (task.upperPrice - minPrice) / (maxPrice - minPrice);
        
    } else if (self.priceLevelSlider) {
        self.priceLevelSlider.lowerValue = (task.priceLevel - 1) / 2;
    }
    
    if (self.personSlider) {
        CGFloat min = [self personsMinimum];
        CGFloat max = [self personsMaximum];
        self.personSlider.lowerValue = (task.numberOfPersons - min) / (max - min);
    }
    
    if (task.card) {
        self.creditCard = [[DataManager manager] managedObjectWithID:task.card.objectId withEntityName:@"CreditCard" inContext:[NSManagedObjectContext contextForCurrentThread]];
    } else {
        self.creditCard = [[User currentUser] defaultCard];
    }
    
    [self updateCreditCard];
}

- (PTask *)inputData
{
    
    CGFloat price;
    CGFloat minPrice = [self priceMinimum];
    CGFloat maxPrice = [self priceMaximum];
    
    
    PTask *res = [PTask object];
    
    if (self.startDate)
        res.date = self.startDate;
    
    res.desc = nil;
    res.type = self.taskType;
    res.type2 = self.subTaskType;
    res.note = self.txtNote.text ?: @"";
    
    if (self.priceRangeSlider)
    {
        price = round(self.priceRangeSlider.lowerValue * (maxPrice - minPrice) + minPrice);
        price = round(price / 100) * 100;
        res.lowerPrice = price;
        
        price = round(self.priceRangeSlider.upperValue * (maxPrice - minPrice) + minPrice);
        price = round(price / 100) * 100;
        res.upperPrice = price;
    }
    else if (self.priceLevelSlider)
    {
        res.priceLevel = roundf(self.priceLevelSlider.lowerValue * 2 + 1);
    }
    
    
    if (self.personSlider)
    {
        CGFloat min = [self personsMinimum];
        CGFloat max = [self personsMaximum];
        
        int persons = round(self.personSlider.lowerValue * (max - min) + min);
        res.numberOfPersons = persons;
    }
    
    if (self.creditCard)
        res.card = [PCreditCard objectWithoutDataWithObjectId:self.creditCard.objectId];
    
    return res;
}

- (NSString *)errorMessageForInvalidInputs
{
    if (!self.startDate && self.btnStartDate)
        return [self.btnStartDate titleForState:UIControlStateNormal];
    
    return nil;
}

- (void) resignAllTextInputs
{
    [self.txtNote resignFirstResponder];
}

#pragma mark Side Menu Gesture Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panner
{
    return NO;
}

#pragma mark TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Actions

- (void)onBack:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to go back before saving your task?"message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alertView.tag = 100;
    [alertView show];
}

- (IBAction) onHoldVoiceButton:(UILongPressGestureRecognizer *)sender
{
    if (voiceRecordingState == VR_PROCESSING)
        return;
    
    if ([sender state] == UIGestureRecognizerStateBegan)
    {
        DLog(@"gesture begin");
        if (voiceRecordingState == VR_IDLE) {
            voiceRecordingState = VR_INITIAL;
            [self.voiceRecordingIndicator startAnimationClockWise:YES];
            self.speechRecognizer = [[DataManager manager] createSpeechKitRecognizerWithDelegate:self];
        }
    }
    else if ([sender state] == UIGestureRecognizerStateCancelled ||
             [sender state] == UIGestureRecognizerStateEnded ||
             [sender state] == UIGestureRecognizerStateFailed)
    {
        DLog(@"gesture end");
        if (voiceRecordingState == VR_INITIAL)
            [self.speechRecognizer cancel];
        else
            [self.speechRecognizer stopRecording];
    }
}


- (IBAction)onChangeStartDate:(id)sender
{
    
    self.datePicker.minimumDate = self.minimumDate ?: [NSDate date];
    
    if (self.maximumDate)
        self.datePicker.maximumDate = self.maximumDate;
    
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.datePicker.date = self.startDate ?: [self.datePicker.minimumDate dateInOneHour];
    self.datePicker.minuteInterval = 30;
    self.datePicker.tag = 0;
    
    UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
    [self.datePicker presentInView:window animated:YES completion:nil];
    [self.datePicker setValueChangedListener:self action:@selector(onDateChanged:)];
}

- (IBAction)onChangeEndDate:(id)sender
{
    
    self.datePicker.minimumDate = self.startDate ?: self.endDate ?: [NSDate date];
    
    if (self.maximumDate)
        self.datePicker.maximumDate = self.maximumDate;
    
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.datePicker.date = self.endDate ?: [self.datePicker.minimumDate dateInOneHour];
    self.datePicker.minuteInterval = 30;
    self.datePicker.tag = 1;
    
    UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
    [self.datePicker presentInView:window animated:YES completion:nil];
    [self.datePicker setValueChangedListener:self action:@selector(onDateChanged:)];
}


- (void) onDateChanged:(DatePicker *)datePicker
{
    if (datePicker.tag == 0)
    {
        self.startDate = datePicker.date;
        [self.btnStartDate setAttributedTitle:[self.startDate attributedDateTimeWithSize:15 forTaskType:self.taskType] forState:UIControlStateNormal];
    }
    else
    {
        self.endDate = datePicker.date;
        [self.btnEndDate setAttributedTitle:[self.endDate attributedDateTimeWithSize:15 forTaskType:self.taskType] forState:UIControlStateNormal];
    }
}

- (IBAction)onPickStartLocation:(id)sender
{
    LocationPicker *picker = [LocationPicker locationPicker];
    picker.tag = 0;
    picker.coordinate = self.startLocation;
    picker.delegate = self;
    picker.view.backgroundColor = self.view.backgroundColor;
    [self.navigationController pushViewController:picker animated:YES];
}

- (IBAction)onPickEndLocation:(id)sender
{
    LocationPicker *picker = [LocationPicker locationPicker];
    picker.tag = 1;
    picker.coordinate = self.endLocation;
    picker.delegate = self;
    picker.view.backgroundColor = self.view.backgroundColor;
    [self.navigationController pushViewController:picker animated:YES];
}

- (void)locationPicker:(LocationPicker *)picker didFinishWithResult:(CLLocationCoordinate2D)result
{
    if (picker.tag == 0)
    {
        self.startLocation = result;
        [self.btnStartLocation setTitle:[NSString stringWithFormat:@"%.6f, %.6f", result.latitude, result.longitude] forState:UIControlStateNormal];
    }
    else
    {
        self.endLocation = result;
        [self.btnEndLocation setTitle:[NSString stringWithFormat:@"%.6f, %.6f", result.latitude, result.longitude] forState:UIControlStateNormal];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onPersonSliderChanged:(id)sender
{
    CGPoint center;
    CGRect frame = self.personSlider.frame;;
    CGFloat gap = 13;
    CGFloat persons;
    CGFloat min = [self personsMinimum];
    CGFloat max = [self personsMaximum];
    
    persons = round(self.personSlider.lowerValue * (max - min) + min);
    center = self.numberOfPersonsLabel.center;
    center.x = CGRectGetMinX(frame) + gap + (frame.size.width - gap * 2) * self.personSlider.lowerValue;
    self.numberOfPersonsLabel.center = center;
    self.numberOfPersonsLabel.text = [NSString stringWithFormat:@"%d", (int)persons];
}

- (IBAction)onPriceLevelSliderChanged:(id)sender
{
    CGFloat stepValue = 1 / 2.f;
    CGFloat newStep = roundf(self.priceLevelSlider.lowerValue / stepValue);
    self.priceLevelSlider.lowerValue = newStep * stepValue;
}

- (IBAction)onPriceRangeSliderChanged:(id)sender
{
    CGPoint center;
    CGRect frame = self.priceRangeSlider.frame;;
    CGFloat gap = 4;
    CGFloat price;
    CGFloat min = [self priceMinimum];
    CGFloat max = [self priceMaximum];
    
    price = round(self.priceRangeSlider.lowerValue * (max - min) + min);
    price = round(price / 100) * 100;
    center = self.lowerPriceLabel.center;
    center.x = CGRectGetMinX(frame) + gap + (frame.size.width - gap * 2) * self.priceRangeSlider.lowerValue - 3;
    self.lowerPriceLabel.center = center;
    self.lowerPriceLabel.text = [NSString stringWithFormat:@"$%d", (int)price];
    
    price = round(self.priceRangeSlider.upperValue * (max - min) + min);
    price = round(price / 100) * 100;
    center = self.upperPriceLabel.center;
    center.x = CGRectGetMinX(frame) + gap + (frame.size.width - gap * 2) * self.priceRangeSlider.upperValue - 3;
    self.upperPriceLabel.center = center;
    self.upperPriceLabel.text = [NSString stringWithFormat:@"$%d", (int)price];
}

- (IBAction)onSelectCreditCard:(id)sender
{
    
}

- (IBAction)onAccessoryDone:(id)sender
{
    [self resignAllTextInputs];
}

- (IBAction)onDone:(id)sender
{
    NSString *errorMsg = nil;
    if ((errorMsg = [self errorMessageForInvalidInputs]))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorMsg message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    
    if (!self.creditCard)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"There are no credit cards currenlty associated with your account, add a card to place an order." message:nil delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        alert.tag = 101;
        [alert show];
        
        return;
    }
    
    TaskConfirmView *confirmView = [TaskConfirmView confirmViewWithParent:self.navigationController.view data:[self inputData]];
    
    if (confirmView)
    {
        confirmView.delegate = self;
        [confirmView show];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"This kind of task will be coming in the next update." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

#pragma mark -

- (void)taskConfirmView:(TaskConfirmView *)view didDismissWithResult:(BOOL)result
{
    
    NSAssert([self.delegate respondsToSelector:@selector(newTaskItemController:didFinishWithResult:)], @"NewTaskBaseViewController's delegate should implement the method newTaskItemController:didFinishWithResult:");
    
    if (result)
    {
        [self.delegate newTaskItemController:self didFinishWithResult:[self inputData]];
    }
    else
    {
        [self.delegate newTaskItemController:self didFinishWithResult:nil];
    }
}

- (void)onNewCardAdded:(id)sender
{
    self.creditCard = [User currentUser].defaultCard;
    [self updateCreditCard];
    [self onDone:nil];
}
#pragma mark Alert View Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100)
    {
        if (buttonIndex == alertView.firstOtherButtonIndex)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if (alertView.tag == 101)
    {
        UIStoryboard *storyboard = [[AppDelegate sharedInstance] mainStoryboard];
        CardInputViewController *cardInputVC = [storyboard instantiateViewControllerWithIdentifier:@"cardInputViewController"];
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:cardInputVC];
        navVC.navigationBar.translucent = NO;
        
        [self.navigationController presentViewController:navVC animated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark Audio Recording Delegate

- (void)voiceRecognizer:(id)recognizer recognizedText:(NSString *)text
{
    // Need to be overriden
}

- (void)recognizerDidBeginRecording:(SKRecognizer *)recognizer
{
    
    voiceRecordingState = VR_RECORDING;
    self.title = @"Recording...";
    
    self.speechStartTime = [NSDate date];
    self.speechTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                                        target:self
                                                      selector:@selector(updateRecordingDuration:)
                                                      userInfo:nil repeats:YES];
}

- (void)recognizerDidFinishRecording:(SKRecognizer *)recognizer
{
    
    voiceRecordingState = VR_PROCESSING;
    self.title = @"Processing...";
    
    [self.voiceRecordingIndicator stopAnimation];
    [self.voiceRecordingIndicator startAnimationClockWise:NO];
    self.voiceButton.highlighted = NO;
    [self.speechTimer invalidate];
    self.speechTimer = nil;
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results
{
    
    long numOfResults = [results.results count];
    
    voiceRecordingState = VR_IDLE;
    
    if (numOfResults > 0)
        [self voiceRecognizer:recognizer recognizedText:[results firstResult]];
    
	if (numOfResults > 1)
		DLog(@"alternative text : %@",[[results.results subarrayWithRange:NSMakeRange(1, numOfResults-1)] componentsJoinedByString:@"\n"]);
    
    if (results.suggestion)
        DLog(@"suggestion : %@", results.suggestion);
    
    self.title = self.viewTitle;
    [self.voiceRecordingIndicator stopAnimation];
	self.speechRecognizer = nil;
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion
{
    
    voiceRecordingState = VR_IDLE;
    
    DLog(@"Recognizer error : %@", error);
    
    if (suggestion) {
        DLog(@"suggestion : %@", suggestion);
        
    }
    
    self.title = self.viewTitle;
    [self.voiceRecordingIndicator stopAnimation];
	self.speechRecognizer = nil;
}


- (NSString *)formattedStringForTime:(NSTimeInterval)interval
{
    int time = (int)interval;
    int secs = time % 60;
	int min = time / 60;
    
    NSString *formattedTime;
	if (interval < 60){
        formattedTime = [NSString stringWithFormat:@"00:%02d", time];
    } else {
        formattedTime =	[NSString stringWithFormat:@"%02d:%02d", min, secs];
    }
    
    return formattedTime;
}

- (void) updateRecordingDuration:(id)sender
{
    NSDate *now = [NSDate date];
    self.title = [self formattedStringForTime:[now timeIntervalSinceDate:self.speechStartTime]];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
