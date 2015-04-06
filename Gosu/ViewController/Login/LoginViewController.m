//
//  LoginViewController.m
//  Gosu
//
//  Created by dragon on 3/19/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "LoginViewController.h"
#import "TextHelper.h"

#import <SVProgressHUD/SVProgressHUD.h>

#import "DataManager.h"
#import "PFUser+Extra.h"

@implementation LoginViewController

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
    
#ifdef DEBUG
    self.txtUserName.text = @"lifeng617@126.com";
    self.txtPassword.text = @"123456";
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.txtUserName becomeFirstResponder];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Actions

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onGo:(id)sender
{
    
    if ([self validateInputs])
    {
        __weak LoginViewController *wself = self;
        GLoginBlock loginBlock = ^(BOOL success, PFUser *user, NSString *errorDesc) {
            [SVProgressHUD dismiss];
            
            LoginViewController *sself = wself;
            if (!success) {
                [[[UIAlertView alloc] initWithTitle:@"Warning" message:errorDesc delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else {
                
                [sself completeLoginProcess];
            }
        };
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [[DataManager manager] loginWithUserName:[self txtUserName].text
                                        Password:[self txtPassword].text
                               CompletionHandler:loginBlock];
    }
}

- (BOOL) validateInputs
{
    NSString *userName = [self txtUserName].text;
    NSString *password = [self txtPassword].text;
    
    if ([userName length] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Login" message:@"Please input your user name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return NO;
    }
    
    if ([password length] < 6) {
        [[[UIAlertView alloc] initWithTitle:@"Login" message:@"You have to provide minimum 6 characters for the password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return NO;
    }
    
    return YES;
}

#pragma mark TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtUserName)
        [self.txtPassword becomeFirstResponder];
    else
        //[self onGo:nil];
        [textField resignFirstResponder];
    
    return YES;
}
@end
