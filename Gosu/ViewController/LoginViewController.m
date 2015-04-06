//
//  LoginViewController.m
//  Gosu
//
//  Created by dragon on 3/19/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "LoginViewController.h"
#import "TextHelper.h"
#import "PFUser+Extra.h"
#import "DataManager.h"
#import <SVProgressHUD/SVProgressHUD.h>


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
        
        [SVProgressHUD showWithStatus:@"Loading..."];
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
        [self onGo:nil];
    
    return YES;
}
@end
