//
//  TaskCollectionViewCell.h
//  Gosu
//
//  Created by dragon on 3/23/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GStarRating;
@class RoundImageView;
@class CreditIndicator;
@class BadgeLabel;
@class Task;
@interface TaskCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIView *backgroundView;
@property (nonatomic, strong) IBOutlet UIView *selectedBackgroundView;
@property (nonatomic, strong) IBOutlet UIView *topView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@property (nonatomic, weak) IBOutlet UIView *employeeInfoView;
@property (nonatomic, weak) IBOutlet RoundImageView *employeePhotoView;
@property (nonatomic, weak) IBOutlet UILabel *employeeNameLabel;
@property (nonatomic, weak) IBOutlet GStarRating *employeeRatingControl;
@property (nonatomic, weak) IBOutlet UIImageView *employeeGosuImageView;

@property (nonatomic, weak) IBOutlet UILabel *employeeNotAssignedLabel;

@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet CreditIndicator *creditsIndicator;
@property (nonatomic, weak) IBOutlet UILabel *creditsLabel;

@property (nonatomic, weak) IBOutlet BadgeLabel *badgeLabel;


- (void)setTask:(Task *)task;
@end
