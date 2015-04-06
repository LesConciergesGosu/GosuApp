//
//  CardInputViewController.h
//  Gosu
//
//  Created by dragon on 3/21/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardCaptureViewController.h"

@interface CardInputViewController : UIViewController<UITextFieldDelegate, CardCaptureViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIButton *doneButton;
@property (nonatomic, weak) IBOutlet UIView *inputView;
@property (nonatomic, weak) IBOutlet UIImageView *imgCardLogo;
@property (nonatomic, weak) IBOutlet UITextField *txtCardNumber;
@property (nonatomic, weak) IBOutlet UITextField *txtExpiryDate;
@property (nonatomic, weak) IBOutlet UITextField *txtCCV;

@property (nonatomic) BOOL showCancelButton;
@end
