//
//  DasboardCell.h
//  Gosu
//
//  Created by Dragon on 10/12/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "SwipeTableViewCell.h"

@class DashboardCell;
@protocol DashboardCellDelegate <NSObject>

@optional
- (void)dashboardSelected:(DashboardCell *)cell;
- (void)dashboardCellDismiss:(DashboardCell *)cell;
- (void)dashboardCellRemindLater:(DashboardCell *)cell;
@end

@interface DashboardCell : SwipeTableViewCell

@property (nonatomic, strong) IBOutlet UILabel *descLabel;
@property (nonatomic, strong) IBOutlet UILabel *placeLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UIImageView *bgImageView;
@property (nonatomic, strong) IBOutlet UIView *colorView;

@property (nonatomic, weak) id<SwipeTableViewCellDelegate, DashboardCellDelegate> delegate;
@end
