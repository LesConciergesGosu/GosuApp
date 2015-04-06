//
//  ProfileEditViewController.h
//  Gosu
//
//  Created by dragon on 6/14/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileEditViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIView *profileView;
@property (nonatomic, weak) IBOutlet UITextField *firstNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *lastNameTextField;
@property (nonatomic, weak) IBOutlet UIView *photoView;
@property (nonatomic, weak) IBOutlet UIButton *addPhotoButton;
@property (nonatomic, weak) IBOutlet UIImageView *photoImageView;
@end
