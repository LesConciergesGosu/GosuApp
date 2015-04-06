//
//  CreateTaskViewController.m
//  Gosu
//
//  Created by dragon on 3/20/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "CreateTaskViewController.h"
#import "PeakCurveSlider.h"
#import "CreditIndicator.h"
#import "BlurModalDialog.h"
#import "CardHelper.h"
#import "CardInputViewController.h"
#import "UIViewController+ViewDeck.h"
#import "DotSpinView.h"
#import "PFUser+Extra.h"
#import "Task+Extra.h"
#import "User+Extra.h"
#import "CreditCard+Extra.h"
#import "Tutorial.h"
#import "DataManager.h"
#import <SpeechKit/SpeechKit.h>
#import <SVProgressHUD/SVProgressHUD.h>

typedef NS_ENUM(NSInteger, TaskCreditOption) {
    TaskCreditOption1,
    TaskCreditOption2,
    TaskCreditOption3,
    TaskCreditOptionCount
};

#define MAX_CREDIT_CARD_BILL_AMOUNT 1

#define ALERT_TAG_ADD_CARD 100
#define ALERT_TAG_LITTLE_FUND 101

@interface CreateTaskViewController ()<SKRecognizerDelegate/*,AudioRecordDelegate*/>
{
    NSInteger creditOption;
    VoiceRecordingState voiceRecordingState;
}
@property (nonatomic, strong) NSString *voicePath;
@property (nonatomic, strong) SKRecognizer *speechRecognizer;
@property (nonatomic, strong) NSTimer *speechTimer;
@property (nonatomic, strong) NSDate *speechStartTime;
@end

@implementation CreateTaskViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"New Task";
    self.attachmentView.hidden = YES;
    
    creditOption = 0;
    voiceRecordingState = VR_IDLE;
    
    [self scrollView].contentSize = CGSizeMake(320, 472);
    
    [self creditIndicator].fillColor = [UIColor colorWithRed:72/255.f green:207/255.f blue:173/255.f alpha:1];
    [self creditIndicator].borderColor = [UIColor colorWithRed:33/255.f green:39/255.f blue:47/255.f alpha:1];
    [self creditIndicator].borderWidth = 2;
    [self creditIndicator].percent = 1 / 3.f;
    
    UIBarButtonItem *keyboardDoneItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:self
                                                      action:@selector(onKeyboardDone:)];
    UIBarButtonItem *leftPaddingItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                      target:nil
                                                      action:nil];
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [toolBar setItems:@[leftPaddingItem, keyboardDoneItem]];
    
    [self descTextView].inputAccessoryView = toolBar;
    [self descTextView].placeholder = @"Add description or attach a voice recording.";
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewCardAdded:) name:NotificationCardAdded object:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    if (self.task) {
        self.title = @"Edit Task";
        
        [self titleTextField].text = [self task].title;
        [self descTextView].text = [self task].desc;
        [self cardAmountSlider].value = [[self task].cardAmount intValue];
        
        if ([self task].voice) {
            self.attachmentView.hidden = NO;
            self.voiceAttachedLabel.text = @"--:--";
        }
        
        creditOption = [[self task].credits intValue] + TaskCreditOptionCount - 1;
        [self onChooseCredits:nil];
        
        [self creditButton].enabled = NO;
        [self cardAmountSlider].enabled = NO;
        [[self cardAmountSlider] setCurrentValue:[[self task].cardAmount intValue]];
    }
    else
    {
        [self onCardAmountChanged:nil];
    }
    
    
    if ([self.navigationController deckController])
        [[self.navigationController deckController] setPanningGestureDelegate:self];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    User *user = [User currentUser];
    
    if (![[user tutorialInstance].fundSlider boolValue]) {
        
        [user tutorialInstance].fundSlider = @(YES);
        
        if ([user.managedObjectContext hasChanges])
            [user.managedObjectContext saveRecursively];
        
        BlurModalDialog *dialog = [[BlurModalDialog alloc] initWithTitle:@"Moving the slider will change the limit we authorize to your card" message:@"For some tasks with a purchase, we need to authorize and hold funds from your credit card first. You can set a limit you authorize your Gosu to spend, they may not need to spend all of it. (ex. hotel rooms, tickets or lunch)" fromView:self.navigationController.view];
        
        [dialog show];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.voicePath)
        [[NSFileManager defaultManager] removeItemAtPath:self.voicePath error:nil];
    
    if ([self.navigationController deckController])
        [[self.navigationController deckController] setPanningGestureDelegate:nil];
    
    [self.speechTimer invalidate];
    self.speechTimer = nil;
    [self.speechRecognizer stopRecording];
    self.speechRecognizer = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Privates
- (void) updateTotalAmount {
    
    NSInteger cardAmount = (NSInteger) (self.cardAmountSlider.value * MAX_CREDIT_CARD_BILL_AMOUNT);
    NSInteger creditAmount = (creditOption + 1) * 25;
    
    self.totalAmountLabel.text = [NSString stringWithFormat:@"$%ld", (long)(cardAmount + creditAmount)];
}

- (BOOL) validateInputFields {
    
    if ([self.titleTextField text].length == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Please input the title of your task."
                                    message:nil
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return NO;
    }
    
    if ([self.descTextView text].length == 0 && (!self.voicePath || ![[NSFileManager defaultManager] fileExistsAtPath:self.voicePath]))
    {
        [[[UIAlertView alloc] initWithTitle:@"Please input the description."
                                    message:nil
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return NO;
    }
    
    if (!self.task) {
        if ([PFUser currentUser].credits < creditOption + 1) {
            [[[UIAlertView alloc] initWithTitle:@"You don't have enough credits. You need to purchase more credits."
                                        message:nil
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            return NO;
        }
        
        NSInteger cardAmount = [self cardAmount];
        
        if (cardAmount == 0)
        {
            [[[UIAlertView alloc] initWithTitle:@"Please fund some from your card or credits."
                                        message:nil
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            
            return NO;
        }
        
        if (![[User currentUser] defaultCard]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"There are no credit cards currenlty associated with your account, add a card to place an order." message:nil delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
            alert.tag = ALERT_TAG_ADD_CARD;
            [alert show];
            return NO;
        }
        
        int hrs = (int)(creditOption + 1) * 2;
        
        if (cardAmount < hrs * 10) {
            NSString *message = [NSString stringWithFormat:@"You fund too little amount, nobody may claim your job. We recommend you to fund at least $%d. Will you proceed anyway?", hrs * 10];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Fund More"
                                                  otherButtonTitles:@"Proceed Anyway", nil];
            alert.tag = ALERT_TAG_LITTLE_FUND;
            [alert show];
            return NO;
        }
    }
    
    return YES;
}

- (int) cardAmount
{
    return (int) (self.cardAmountSlider.value * MAX_CREDIT_CARD_BILL_AMOUNT);;
}

- (void) openTaskConfirmView {
    
    NSString *cardNumber = [[User currentUser] defaultCard].cardNumber;
    
    TaskConfirmView *confrimView = [[TaskConfirmView alloc] initWithParentView:self.navigationController.view];
    [confrimView setDelegate:self];
    [confrimView setBilledCardAmount:(int) (self.cardAmountSlider.value * MAX_CREDIT_CARD_BILL_AMOUNT)
                          andCredits:(int)(creditOption + 1)
                             inHours:(int)(creditOption + 1) * 2];
    [confrimView setRedactedCardNumber:[CardHelper redactedCardNumberFor:cardNumber]];
    confrimView.delegate = self;
    [confrimView show];
}

#pragma mark Text Field / View Delegate

- (void) onKeyboardDone:(id)sender
{
    [self.descTextView resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.titleTextField resignFirstResponder];
    [self.descTextView becomeFirstResponder];
    return YES;
}

#pragma mark Actions
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

- (IBAction) onCardAmountChanged:(id)sender
{
    
    CGRect knobRect = [self.cardAmountView convertRect:[self.cardAmountSlider knobRect]
                                              fromView:self.cardAmountSlider];
    [self cardAmountLabelView].center =
        CGPointMake(CGRectGetMidX(knobRect),CGRectGetMidY(knobRect) - 40);
    [self cardAmountLabel].text =
        [NSString stringWithFormat:@"$%d", (int)(self.cardAmountSlider.value * MAX_CREDIT_CARD_BILL_AMOUNT)];
    
    [self updateTotalAmount];
}

- (IBAction) onChooseCredits:(id)sender
{
    
    creditOption = (creditOption + 1) % TaskCreditOptionCount;
    
    [self creditAmountLabel].text = [NSString stringWithFormat:@"$%ld", (long)(creditOption + 1) * 25];
    [self creditHoursLabel].text = [NSString stringWithFormat:@"< %ldhrs", (long)(creditOption + 1) * 2];
    
    [self creditIndicator].percent = (creditOption + 1) / 3.f;
    
    [self updateTotalAmount];
}

- (IBAction) onGo:(id)sender
{
    if ([self validateInputFields])
    {
        
        if (self.task) {
            //Edit
            GCreateObjectBlock successBlock = ^(BOOL success, PFObject *object, NSString *errorDesc) {
                
                [SVProgressHUD dismiss];
                if (success) {
                    [SVProgressHUD showSuccessWithStatus:@"Success"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationCreatedNewTask object:object];
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Warning"
                                                message:errorDesc
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
            };
            
            [SVProgressHUD showWithStatus:@"Loading..."];
            [self.task editJobPostingWithTitle:[self titleTextField].text
                                   Description:[self descTextView].text
                                 VoiceAttached:self.voicePath
                             CompletionHandler:successBlock];
            return;
        }
        
        if ([[User currentUser] defaultCard]) {
            [self openTaskConfirmView];
        }
    }
}

#pragma mark Task Confrim View Delegate
- (void) taskConfrimView:(TaskConfirmView *)view didDismissWithResult:(BOOL)result
{
    if (result) {
        
        // Create
        
        GCreateObjectBlock successBlock = ^(BOOL success, PFObject *object, NSString *errorDesc) {
            
            [SVProgressHUD dismiss];
            if (success) {
                [SVProgressHUD showSuccessWithStatus:@"Created New Task"];
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationCreatedNewTask object:object];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Warning"
                                            message:errorDesc
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }
        };
        
        [SVProgressHUD showWithStatus:@"Loading..."];
        [Task createNewTaskWithTitle:[self titleTextField].text
                         Description:[self descTextView].text
                               Hours:(int)(creditOption + 1) * 2
                             Credits:(int)(creditOption + 1)
                                Card:[[User currentUser] defaultCard]
                          CardAmount:[self cardAmount]
                       VoiceAttached:self.voicePath
                   CompletionHandler:successBlock];
    }
}

#pragma mark Audio Recording Delegate

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
        self.descTextView.text = [results firstResult];
    
	if (numOfResults > 1)
		DLog(@"alternative text : %@",[[results.results subarrayWithRange:NSMakeRange(1, numOfResults-1)] componentsJoinedByString:@"\n"]);
    
    if (results.suggestion)
        DLog(@"suggestion : %@", results.suggestion);
    
    self.title = @"New Task";
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
    
    self.title = @"New Task";
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

//- (void)audioManager:(AudioManager *)manager didFinishWithSucess:(BOOL)success recordedPath:(NSString *)path duration:(NSTimeInterval)duration
//{
//    if (success) {
//        self.attachmentView.hidden = NO;
//        self.voiceAttachedLabel.text = [NSString stringWithFormat:@"(%@)", [self formattedStringForTime:duration]];
//        self.voicePath = path;
//    } else {
//        self.attachmentView.hidden = YES;
//        self.voiceAttachedLabel.text = @"";
//        self.voicePath = nil;
//    }
//}
//
//- (void)audioManager:(AudioManager *)manager UpdateRecordingTime:(NSTimeInterval)interval
//{
//    self.title = [self formattedStringForTime:interval];
//}

#pragma mark Side Menu Gesture Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panner
{
    return NO;
}

#pragma mark Alert View

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ALERT_TAG_LITTLE_FUND) {
        
        if (buttonIndex == alertView.firstOtherButtonIndex &&
            [[User currentUser] defaultCard]) {
            [self openTaskConfirmView];
        }
        
    } else if (alertView.tag == ALERT_TAG_ADD_CARD) {
        CardInputViewController *cardInputVC = [self.storyboard instantiateViewControllerWithIdentifier:@"cardInputViewController"];
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:cardInputVC];
        navVC.navigationBar.translucent = NO;
        
        [self.navigationController presentViewController:navVC animated:YES completion:nil];
    }
}

#pragma mark Card Add Notification

- (void)onNewCardAdded:(id)sender
{
    [self onGo:nil];
}

@end
