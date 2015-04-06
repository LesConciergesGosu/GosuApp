//
//  TaskDetailViewController.h
//  Gosu
//
//  Created by Dragon on 10/14/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;
@class RoundImageView;
@class GStarRating;
@interface TaskDetailViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *contentView;

@property (nonatomic, weak) IBOutlet UIView *gosuView;
@property (nonatomic, weak) IBOutlet RoundImageView *photoView;
@property (nonatomic, weak) IBOutlet UILabel *lblName;
@property (nonatomic, weak) IBOutlet GStarRating *userRatingControl;
@property (nonatomic, weak) IBOutlet UIView *badgeView;

@property (nonatomic, weak) IBOutlet UIImageView *taskCoverImageView;
@property (nonatomic, weak) IBOutlet UILabel *lblType;
@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblStatus;

@property (nonatomic, weak) IBOutlet UIView *detailView;
@property (nonatomic, weak) IBOutlet UILabel *lblDate;
@property (nonatomic, weak) IBOutlet UILabel *lblDate2;
@property (nonatomic, weak) IBOutlet UILabel *lblPersons;
@property (nonatomic, weak) IBOutlet UILabel *lblCost;
@property (nonatomic, weak) IBOutlet UILabel *lblNote;

@property (nonatomic, strong) IBOutlet UIButton *btnDone;

@property (nonatomic, strong) Task *task;
@end
