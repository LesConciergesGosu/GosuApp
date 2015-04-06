//
//  TaskCustomerCell.h
//  Gosu
//
//  Created by Dragon on 10/14/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TaskCustomerCell;
@protocol TaskCustomerCellDelegate <NSObject>

- (void)taskCustomerCellMessages:(TaskCustomerCell *)cell;

@end

@class Task;
@class GStarRating;
@class RoundImageView;
@interface TaskCustomerCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIView *topView;
@property (nonatomic, weak) IBOutlet UIImageView *topImageView;
@property (nonatomic, weak) IBOutlet UILabel *typeLabel;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

// Detail Section
@property (nonatomic, weak) IBOutlet UILabel *lblDate;
@property (nonatomic, weak) IBOutlet UILabel *lblDate2;
@property (nonatomic, weak) IBOutlet UILabel *lblPersons;
@property (nonatomic, weak) IBOutlet UILabel *lblCost;
@property (nonatomic, weak) IBOutlet UIView *badgeView;

// Gosu Section
@property (nonatomic, weak) IBOutlet UIView *employeeInfoView;
@property (nonatomic, weak) IBOutlet RoundImageView *employeePhotoView;
@property (nonatomic, weak) IBOutlet UILabel *employeeNameLabel;
@property (nonatomic, weak) IBOutlet GStarRating *employeeRatingControl;
@property (nonatomic, weak) IBOutlet UIImageView *employeeGosuImageView;

@property (nonatomic, weak) id<TaskCustomerCellDelegate> delegate;

- (void)setTask:(Task *)task;

@end
