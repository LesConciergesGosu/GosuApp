//
//  NotificationCell.h
//  Gosu
//
//  Created by dragon on 6/15/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemovableCell.h"

@class Notification;
@interface NotificationCell : RemovableCell


@property (nonatomic, strong) IBOutlet UIImageView *photoView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UIImageView *timer;
@property (nonatomic, strong) IBOutlet UIImageView *indicator;


+ (CGFloat)heightForData:(Notification *)data;
@end
