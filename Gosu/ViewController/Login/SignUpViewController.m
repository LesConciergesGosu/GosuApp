//
//  SignUpViewController.m
//  Gosu
//
//  Created by dragon on 3/19/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "SignUpViewController.h"
#import "TextHelper.h"
#import "UIImage+Resize.h"

#import <SVProgressHUD/SVProgressHUD.h>

#import "PFUser+Extra.h"
#import "DataManager.h"

@interface SignUpViewController ()
@end


@implementation SignUpViewController

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
    
    self.scrollView.contentSize = CGSizeMake(320, 230);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) keyboardWillShow:(id)sender
{
    
    // When keyboard appear, we need to shrink the height of contentView with
    // an animation appropriate with keyboard show animation
    
    NSDictionary *userInfo = [sender userInfo];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect frame = self.view.bounds;
    CGRect buttonFrame = self.btnCancel.frame;
    buttonFrame.origin.y = frame.size.height - endFrame.size.height - buttonFrame.size.height - 30;
    
    if (buttonFrame.origin.y < CGRectGetMaxY(self.btnDone.frame) + 30)
        buttonFrame.origin.y = CGRectGetMaxY(self.btnDone.frame) + 30;
    
    [UIView animateWithDuration:duration delay:0 options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.btnCancel.frame = buttonFrame;
    } completion:^(BOOL finished) {
    }];
}

- (void) keyboardWillHide:(id)sender
{
    
    // When keyboard disppear, we need to expand the height of contentView with
    // an animation appropriate with keyboard hide animation
    
    NSDictionary *userInfo = [sender userInfo];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    CGRect frame = self.view.bounds;
    CGRect buttonFrame = self.btnCancel.frame;
    buttonFrame.origin.y = frame.size.height - buttonFrame.size.height - 30;
    
    [UIView animateWithDuration:duration delay:0 options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.btnCancel.frame = buttonFrame;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark Actions

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onGo:(id)sender
{
    
    if ([self validateInputs]) {
        
        __weak typeof (self) wself = self;
        
        GLoginBlock loginBlock = ^(BOOL success, PFUser *pUser, NSString *errorDesc) {
            
            [SVProgressHUD dismiss];
            
            SignUpViewController *sself = wself;
            if (!sself)
                return;
            
            if (success) {
                [sself completeLoginProcess];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Warning" message:errorDesc delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        };
        
#ifdef DEBUG
        NSString *password = @"123456";
#else
        NSString *password = [self generateRandomPassword];
#endif
        
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [[DataManager manager] signUpWithFirstName:[self txtFirstName].text
                                          LastName:[self txtLastName].text
                                          UserName:[self txtEmail].text
                                             Email:[self txtEmail].text
                                          Password:password
                                              Type:USER_TYPE
                                             Photo:nil
                                 CompletionHandler:loginBlock];
    }
    
    
}

- (NSString *)generateRandomPassword {
    
    static NSString *headCharacter = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    static NSString *character = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
    
    NSInteger headLength = [headCharacter length];
    NSInteger charLength = [character length];
    
    
    int len = arc4random() % 10 + 6;
    NSMutableString *password = [[NSMutableString alloc] initWithCapacity:len];
    [password appendFormat:@"%C", [headCharacter characterAtIndex:arc4random() % headLength]];
    for (int i = 1; i < len; i ++) {
        [password appendFormat:@"%C", [character characterAtIndex:arc4random() % charLength]];
    }
    
    return password;
}

- (BOOL)validateInputs
{
    NSString *email = [self txtEmail].text;
    
    if ([[self txtFirstName].text length] == 0 ||
        [[self txtLastName].text length] == 0 ||
        [[self txtEmail].text length] == 0 ||
        [[self txtFirstName].text length] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Login" message:@"Please fill in all fields." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return NO;
    }
    
    if (![TextHelper textIsValidEmailFormat:email])
    {
        [[[UIAlertView alloc] initWithTitle:@"Login" message:@"Provided email is invalid." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return NO;
    }
    
    return YES;
}

#pragma mark TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtFirstName)
        [self.txtLastName becomeFirstResponder];
    else if (textField == self.txtLastName)
        [self.txtEmail becomeFirstResponder];
    else if (textField == self.txtEmail)
        [self.txtEmail resignFirstResponder];
    
    return YES;
}

@end
