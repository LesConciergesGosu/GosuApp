//
//  ProfileViewController.h
//  Gosu
//
//  Created by dragon on 3/23/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RightRootViewController.h"

@class User;
@interface ProfileViewController : RightRootViewController

@property (nonatomic, strong) User *user;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *headerView;

@property (nonatomic, weak) IBOutlet UILabel *fullNameLabel;
@property (nonatomic, weak) IBOutlet UIButton *fullNameButton;
@property (nonatomic, weak) IBOutlet UIView *photoView;
@property (nonatomic, weak) IBOutlet UIImageView *photoImageView;
@property (nonatomic, weak) IBOutlet UILabel *lblCountOfOngoingTasks;
@property (nonatomic, weak) IBOutlet UILabel *lblCountOfCompletedTasks;
@property (nonatomic, weak) IBOutlet UILabel *lblSavedHours;


@end
