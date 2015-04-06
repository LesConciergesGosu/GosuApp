//
//  CardInputViewController.m
//  Gosu
//
//  Created by dragon on 3/21/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "CardInputViewController.h"
#import "CardHelper.h"
#import "User+Extra.h"
#import "AppDelegate.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface CardInputViewController ()<CardIOPaymentViewControllerDelegate>
{
    UIImageView *ccImage;
    
	NSInteger currentYear;
    
    CardIOCreditCardType cardType;		// brand
    BOOL haveFullNumber;		// got a full number
    NSUInteger numberLength;	// length of formatted number only
    NSString *creditCardNum;	// real number not the formatted one
    NSString *promptCardNum;
    NSInteger month;			// two digits
	NSInteger year;				// two digits
}
@end

@implementation CardInputViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    DLog(@"CardInputViewController deallocated");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    haveFullNumber = NO;
    numberLength = 0;
    promptCardNum = @"";
    
    
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy"];
    currentYear = [[dateFormatter stringFromDate:[NSDate date]] integerValue] - 2000;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.showCancelButton) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancel:)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    BOOL ret = NO;
    
    NSString *formattedText;
    BOOL flashForError = NO;
    BOOL updateText = NO;
    BOOL scrollForward = NO;
    BOOL deleting = NO;
    BOOL deletedSpace = NO;
    NSString *promptText;
    
    if([string length] == 0) {
        updateText = YES;
        deleting = YES;
        if([textField.text length]) {	// handle case of delete when there are no characters left to delete
            unichar c = [textField.text characterAtIndex:range.location];
            if(range.location && range.length == 1 && (c == ' ' || c == '/')) {
                --range.location;
                ++range.length;
                deletedSpace = YES;
            }
        }
    }
    
    
    NSString *newTextOrig = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSUInteger newTextLen = [newTextOrig length];
    
    if (textField == self.txtCardNumber)
    {
        NSString *newText = [newTextOrig stringByReplacingOccurrencesOfString:@" " withString:@""];
		NSUInteger len = [newText length];
		if(len < 4) {
			updateText = YES;
			formattedText = newTextOrig;
			cardType = CardIOCreditCardTypeAmbiguous;
		} else {
            cardType = [CardHelper ccType:newText];
			if(cardType == CardIOCreditCardTypeUnrecognized) {
				flashForError = YES;
				goto eND;
			}
			if(len == 4) {
				promptCardNum = [CardHelper cardNumberPromptForType:cardType];
                self.txtCCV.placeholder = [CardHelper ccvPromptForType:cardType];
			}
			formattedText = [CardHelper cardNumberFormatForViewing:newText];
			NSUInteger lenForCard = [CardHelper lengthOfCardNumberForType:cardType];
            
			if(len < lenForCard) {
				updateText = YES;
			} else
                if(len == lenForCard) {
                    if([CardHelper isValidNumber:newText]) {
                        if([CardHelper isLuhnValid:newText]) {
                            numberLength = [CardHelper lengthOfFormattedCardNumberForType:cardType];
                            creditCardNum = newText;
                            
                            updateText = YES;
                            scrollForward = YES;
                            haveFullNumber = YES;
                        } else {
                            flashForError = YES;
                        }
                    } else {
                        flashForError = YES;
                    }				
                }
		}
		[self updateCCimageWithTransitionTime:0.25f];
        
        
    eND:
        // Order of these blocks important!
        if(scrollForward) {
            [self.txtExpiryDate setEnabled:YES];
            [self.txtCCV setEnabled:YES];
            [self.txtCardNumber resignFirstResponder];
            [self.txtExpiryDate becomeFirstResponder];
        }
        else
        {
            [self.txtExpiryDate setEnabled:NO];
            [self.txtCCV setEnabled:NO];
        }
        if(updateText) {
            NSUInteger textViewLen = [formattedText length];
            NSUInteger formattedLen = [promptCardNum length];
            //placeView.showTextOffset = MIN(textViewLen, formattedLen);
            
            if((formattedLen > textViewLen) && !deleting) {
                unichar c = [promptCardNum characterAtIndex:textViewLen];
                if(c == ' ') formattedText = [formattedText stringByAppendingString:@" "];
                else
                    if(c == '/') formattedText = [formattedText stringByAppendingString:@"/"];
            }
            if(!deleting || haveFullNumber || deletedSpace) {
                textField.text = formattedText;
            } else {
                ret = YES; // let textView do it to preserve the cursor location. User updating an incorrect number
            }
            // NSLog(@"formattedText=%@ PLACEVIEW=%@ showTextOffset=%u offset=%@ ret=%d", formattedText, placeView.text, placeView.showTextOffset, NSStringFromCGRect(placeView.offset), ret );
            
        }
        if(flashForError)
            self.txtCardNumber.textColor = [UIColor redColor];
        else
            self.txtCardNumber.textColor = APP_COLOR_TEXT_BLACK;
        
    } else if (self.txtExpiryDate == textField) {
        
		// Test for delete of a space or /
		if(deleting) {
			formattedText = [newTextOrig substringToIndex:range.location];	// handles case of deletion interior to the string
			updateText = YES;
            
			goto eNDE;
		}
        
		if(newTextLen > 5) {
			goto eNDE;
		}
        
		formattedText = newTextOrig;
		
        NSRange monthRange = NSMakeRange(0, 2);
		if(newTextLen > monthRange.location) {
			if([newTextOrig characterAtIndex:monthRange.location] > '1') {
				// support short cut - we prepend a '0' for them
				formattedText = newTextOrig = [textField.text stringByReplacingCharactersInRange:range withString:[@"0" stringByAppendingString:string]];
				newTextLen = [newTextOrig length];
			}
			if(newTextLen >= (monthRange.location + monthRange.length)) {
				month = [[newTextOrig substringWithRange:monthRange] integerValue];
				if(month < 1 || month > 12) {
					flashForError = YES;
					goto eNDE;
				}
			}
		}
        
		NSRange yearRange = NSMakeRange(3, 2);
		if(newTextLen > yearRange.location) {
			NSInteger proposedDecade = ([newTextOrig characterAtIndex:yearRange.location] - '0') * 10;
			NSInteger yearDecade = currentYear - (currentYear % 10);
			if(proposedDecade < yearDecade) {
				flashForError = YES;
				goto eNDE;
			}
			if(newTextLen >= (yearRange.location + yearRange.length)) {
				year = [[newTextOrig substringWithRange:yearRange] integerValue];
				NSInteger diff = year - currentYear;
				if(diff < 0/* || diff > 10*/) {	// blogs on internet suggest some CCs have dates 50 yeras in the future
					flashForError = YES;
					goto eNDE;
				}
			}
		}
		
		updateText = YES;
        

    eNDE:
        promptText = @"XX/XX";
         // Order of these blocks important!
        if(newTextLen >= 5) {
            [self.txtExpiryDate resignFirstResponder];
            [self.txtCCV becomeFirstResponder];
        }
        
        if ([textField.text length] == 0  && newTextLen == 0 && deleting)
        {
            [self.txtExpiryDate resignFirstResponder];
            [self.txtCardNumber becomeFirstResponder];
        }
        
        if(updateText) {
            NSUInteger textViewLen = [formattedText length];
            NSUInteger formattedLen = [promptText length];
            //placeView.showTextOffset = MIN(textViewLen, formattedLen);
            
            if((formattedLen > textViewLen) && !deleting) {
                unichar c = [promptText characterAtIndex:textViewLen];
                if(c == ' ') formattedText = [formattedText stringByAppendingString:@" "];
                else
                    if(c == '/') formattedText = [formattedText stringByAppendingString:@"/"];
            }
            if(!deleting || haveFullNumber || deletedSpace) {
                textField.text = formattedText;
            } else {
                ret = YES; // let textView do it to preserve the cursor location. User updating an incorrect number
            }
        }
        
        if (flashForError)
            textField.textColor = [UIColor redColor];
        else
            textField.textColor = APP_COLOR_TEXT_BLACK;
        
    }
    else if (textField == self.txtCCV)
    {
        int length = [CardHelper ccvLengthForType:cardType];
        
        if (newTextLen == length) {
            [self doneButton].enabled = YES;
            [textField resignFirstResponder];
            [textField setText:newTextOrig];
        } else if (newTextLen > length) {
            //nothing
        } else if (newTextLen == 0 && [textField.text length] == 0 && deleting) {
            [textField resignFirstResponder];
            [self.txtExpiryDate becomeFirstResponder];
            updateText = YES;
        } else {
            [textField setText:newTextOrig];
        }
    }
    
    return ret;
}

- (void)updateCCimageWithTransitionTime:(CGFloat)ttime
{
	if(self.imgCardLogo.tag != cardType) {
        
        self.imgCardLogo.image = [CardIOCreditCardInfo logoForCardType:cardType];
        self.imgCardLogo.tag = cardType;
	}
}

#pragma mark Actions

- (void) goBackWithAnimation:(BOOL)animation {
    if (self.navigationController) {
        if ([self.navigationController.viewControllers indexOfObject:self] == 0) {
            //root view controller
            [self.navigationController dismissViewControllerAnimated:animation completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:animation];
        }
    } else {
        //presented
        [self dismissViewControllerAnimated:animation completion:nil];
    }
}

- (void)onCancel:(id)sender
{
    [self goBackWithAnimation:YES];
}

- (IBAction)onDone:(id)sender
{
    if ([self validateInputsWithAlert:YES]) {
        
        CardIOCreditCardInfo *info = [[CardIOCreditCardInfo alloc] init];
        info.cardNumber = [self.txtCardNumber text];
        info.expiryMonth = month;
        info.expiryYear = year;
        info.cvv = [self.txtCCV text];
        
        [SVProgressHUD showWithStatus:@""];
        
        __weak typeof(self) wself = self;
        [[User currentUser] addCreditCard:info CompletionHandler:^(BOOL success, NSString *errorDesc) {
            [SVProgressHUD dismiss];
            CardInputViewController *sself = wself;
            if (success) {
                [sself goBackWithAnimation:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationCardAdded object:nil];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Warning" message:errorDesc delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
    }
}

- (BOOL) validateInputsWithAlert:(BOOL)showAlert
{
    
    if (![CardHelper isLuhnValid:[self.txtCardNumber text]])
    {
        if (showAlert)
            [[[UIAlertView alloc] initWithTitle:@"Warning"
                                        message:@"Your credit card is invalid. Please confirm your card number."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        
        return NO;
    }
    
    if (month <= 0 || month > 12 || year < 14 || year >= 100)
    {
        if (showAlert)
            [[[UIAlertView alloc] initWithTitle:@"Warng"
                                        message:@"Expiry date is invalid. Please confirm again."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        
        return NO;
    }
    
    if ([self.txtCCV text].length != [CardHelper ccvLengthForType:cardType])
    {
        if (showAlert)
            [[[UIAlertView alloc] initWithTitle:@"Warning"
                                        message:@"CCV is invalid. Please confirm again."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    CardIOPaymentViewController *vc = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self scanningEnabled:YES];
//    vc.appToken = kCardIOAppTocken;
//    vc.collectCVV = YES;
//    vc.collectExpiry = YES;
//    vc.collectPostalCode = YES;
//    [[AppDelegate sharedInstance].rootViewController presentViewController:vc animated:YES completion:nil];
//    return;
    if ([segue.destinationViewController isKindOfClass:[CardCaptureViewController class]])
    {
        CardCaptureViewController *captureVC = (CardCaptureViewController *)segue.destinationViewController;
        captureVC.delegate = self;
    }
}

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    [[AppDelegate sharedInstance].rootViewController dismissViewControllerAnimated:YES completion:nil];
}
- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)cardInfo inPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    [[AppDelegate sharedInstance].rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) cardCaptureViewController:(CardCaptureViewController *)vc didScanCard:(CardIOCreditCardInfo *)cardInfo
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (cardInfo) {
        self.txtCardNumber.text = [CardHelper cardNumberFormatForViewing:cardInfo.cardNumber];
        cardType = [CardHelper ccType:cardInfo.cardNumber];
        [self updateCCimageWithTransitionTime:0];
        [self doneButton].enabled = [self validateInputsWithAlert:NO];
        
        NSInteger m = cardInfo.expiryMonth % 100;
        NSInteger y = cardInfo.expiryYear % 100;
        
        if (m > 0) { // valid expiry date
            
            year = y;
            month = m;
            self.txtExpiryDate.text = [NSString stringWithFormat:@"%02i/%02i", (int)month, (int)year];
            
            if ([cardInfo.cvv length] > 0) {
                self.txtCCV.text = cardInfo.cvv;
            } else {
                [self.txtCCV becomeFirstResponder];
            }
        } else {
            [self.txtExpiryDate becomeFirstResponder];
        }
    }
}
 
@end
