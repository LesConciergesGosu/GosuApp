//
//  SplashViewController.h
//  Gosu
//
//  Created by dragon on 3/19/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginBaseViewController.h"

@interface SplashViewController : LoginBaseViewController

@property (nonatomic, weak) IBOutlet UIImageView *logoView;
@property (nonatomic, weak) IBOutlet UIView *buttonSection;
@end
