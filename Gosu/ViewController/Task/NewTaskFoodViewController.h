//
//  NewTaskFoodViewController.h
//  Gosu
//
//  Created by Dragon on 10/14/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewTaskBaseViewController.h"

@interface NewTaskFoodViewController : NewTaskBaseViewController

@property (nonatomic, strong) IBOutlet UITextField *txtTarget;

@property (nonatomic, strong) IBOutlet UIButton *btnASAP;
@property (nonatomic, strong) IBOutlet UIButton *btnCuisine;
@property (nonatomic, strong) IBOutlet UIView *cuisineChooserView;
@property (nonatomic, strong) IBOutlet UIPickerView *cuisineChooser;
@end
