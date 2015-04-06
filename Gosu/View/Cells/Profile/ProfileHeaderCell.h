//
//  ProfileHeaderCell.h
//  Gosu
//
//  Created by dragon on 5/26/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;
@interface ProfileHeaderCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *imvPhoto;
@property (nonatomic, strong) IBOutlet UILabel *lblCompletedTasks;
@property (nonatomic, strong) IBOutlet UILabel *lblOngoingTasks;
@property (nonatomic, strong) IBOutlet UILabel *lblSavedHours;

- (void) loadUser:(User *)user;
@end
