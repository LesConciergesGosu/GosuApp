//
//  EditExperienceViewController.h
//  Gosu
//
//  Created by Dragon on 11/26/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Experience;
@interface EditExperienceViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) Experience *experience;
@end