//
//  SplashViewController.m
//  Gosu
//
//  Created by dragon on 3/19/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "SplashViewController.h"
#import <Reachability/Reachability.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "PFUser+Extra.h"
#import "DataManager.h"

@implementation SplashViewController

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
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)] ) {
        [self.navigationController interactivePopGestureRecognizer].enabled = NO;
    }
    
    if ([PFUser currentUser]) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        __weak SplashViewController *wself = self;
        [[DataManager manager] autoLoginWithCompletionHandler:^(BOOL success, PFUser *user, NSString *errorDesc) {
            [SVProgressHUD dismiss];
            
            SplashViewController *sself = wself;
            if (success) {
                [sself completeLoginProcess];
            } else {
                [sself showLoginButtonsWithAnimation:YES];
            }
        }];
    } else {
        [self showLoginButtonsWithAnimation:YES];
    }
}

- (void) showLoginButtonsWithAnimation:(BOOL)animation {
    CGPoint center = self.logoView.center;
    center.y = 160;
    if (animation) {
        [UIView animateWithDuration:.5f delay:.5f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.logoView.center = center;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.5f animations:^{
                self.buttonSection.alpha = 1;
            }];
        }];
    } else {
        self.logoView.center = CGPointMake(160, 160);
        self.buttonSection.alpha = 1;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Actions

- (IBAction)onFacebookLogin:(id)sender
{
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    __weak SplashViewController *wself = self;
    [[DataManager manager] loginFacebookWithCompletionHandler:^(BOOL success, PFUser *user, NSString *errorDesc) {
        [SVProgressHUD dismiss];
        SplashViewController *sself = wself;
        if (success) {
            [sself completeLoginProcess];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Warning"
                                        message:errorDesc ? errorDesc : @"Unknown Error"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    }];
}

@end
