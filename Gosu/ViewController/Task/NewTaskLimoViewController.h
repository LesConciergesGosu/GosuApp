//
//  NewTaskLimoViewController.h
//  Gosu
//
//  Created by Dragon on 10/14/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "NewTaskBaseViewController.h"

@interface NewTaskLimoViewController : NewTaskBaseViewController

@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, weak) IBOutlet UITextField *txtHours;

@property (nonatomic, weak) IBOutlet UIView *viewLocation;
@property (nonatomic, weak) IBOutlet UIView *viewHours;
@property (nonatomic, weak) IBOutlet UIView *viewOthers;
@end
