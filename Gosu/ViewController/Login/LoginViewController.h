//
//  LoginViewController.h
//  Gosu
//
//  Created by dragon on 3/19/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginBaseViewController.h"

@interface LoginViewController : LoginBaseViewController

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UITextField *txtUserName;
@property (nonatomic, weak) IBOutlet UITextField *txtPassword;
@property (nonatomic, weak) IBOutlet UIButton *btnDone;
@property (nonatomic, weak) IBOutlet UIButton *btnCancel;
@end
