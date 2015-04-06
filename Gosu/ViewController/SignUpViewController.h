//
//  SignUpViewController.h
//  Gosu
//
//  Created by dragon on 3/19/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginBaseViewController.h"
#import "RoundImageView.h"

@interface SignUpViewController : LoginBaseViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UITextField *txtFirstName;
@property (nonatomic, weak) IBOutlet UITextField *txtLastName;
@property (nonatomic, weak) IBOutlet UITextField *txtEmail;
@property (nonatomic, weak) IBOutlet UIButton *doneButton;
@end
