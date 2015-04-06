//
//  SideMenuCell.h
//  Gosu
//
//  Created by dragon on 7/20/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BadgeLabel;
@interface SideMenuCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet BadgeLabel *badgeLabel;
@end
