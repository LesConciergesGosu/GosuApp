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

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UITextField *txtUserName;
@property (nonatomic, weak) IBOutlet UITextField *txtPassword;
@end
