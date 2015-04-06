//
//  NewTaskFlightViewController.h
//  Gosu
//
//  Created by Dragon on 10/12/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "NewTaskBaseViewController.h"

@interface NewTaskFlightViewController : NewTaskBaseViewController

@property (nonatomic, strong) IBOutlet UITextField *txtTarget;

@property (nonatomic, strong) IBOutlet UITextField *txtAdults;
@property (nonatomic, strong) IBOutlet UITextField *txtChildren;
@property (nonatomic, strong) IBOutlet UITextField *txtInfants;

@end
