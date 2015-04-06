//
//  DashboardViewController.h
//  Gosu
//
//  Created by Dragon on 9/30/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "RightRootViewController.h"
#import "BadgeLabel.h"

@interface DashboardViewController : RightRootViewController

@property (nonatomic, strong) IBOutlet BadgeLabel *menuBadgeLabel;

@property (nonatomic, strong) IBOutlet UIView *navBar;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) IBOutlet UIView *profileView;
@property (nonatomic, strong) IBOutlet UIImageView *photoView;
@property (nonatomic, strong) IBOutlet UIImageView *profileBGView;
@property (nonatomic, weak) IBOutlet UIView *welcomeView;
@property (nonatomic, weak) IBOutlet UIImageView *welcomePin;
@property (nonatomic, weak) IBOutlet UILabel *welcomeLabel;
@property (nonatomic, weak) IBOutlet UILabel *welcomeLabel2;
@property (nonatomic, weak) IBOutlet UIView *offerNotifyView;

@property (nonatomic, strong) IBOutlet UIButton *popupButton;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@end
