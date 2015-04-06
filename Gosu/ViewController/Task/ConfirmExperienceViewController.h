//
//  ConfirmExperienceViewController.h
//  Gosu
//
//  Created by Dragon on 12/6/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Experience;
@interface ConfirmExperienceViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *editingHeaderView;
@property (nonatomic, strong) Experience *experience;

@property (nonatomic, strong) IBOutlet UIView *confirmButtonView;

@end
