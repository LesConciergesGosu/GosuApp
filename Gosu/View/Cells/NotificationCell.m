//
//  NotificationCell.m
//  Gosu
//
//  Created by dragon on 6/15/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "NotificationCell.h"
#import "Notification+Extra.h"
#import "User+Extra.h"
#import "DataManager.h"

@interface NotificationCell()

@end

@implementation NotificationCell

+ (CGFloat)heightForData:(Notification *)data {
    
    CGSize size = [data.message sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(250, 1000)];
    
    return size.height + 24;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setData:(Notification *)data
{
    
    [super setData:data];
    
    User *sender = data.from;
    
    // sender photo & name
    if (sender) {
        [self titleLabel].text = [sender fullName];
        [self photoView].image = [UIImage imageNamed:@"buddy.png"];
        NSString *photoUrlString = [sender photo];
        if (photoUrlString)
        {
            __weak NotificationCell *wself = self;
            [[DataManager manager] loadImageURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:photoUrlString]] handler:^(UIImage *image) {
                NotificationCell *sself = wself;
                if (sself && sself.data == data && image) {
                    [sself photoView].image = image;
                }
            }];
        }
    } else {
        [self photoView].image = [UIImage imageNamed:@"logo_black.png"];
        [self titleLabel].text = @"Gosu";
    }
    
    // message
    [self messageLabel].text = data.message;
    
    // date
    NSDate *date = data.createdAt;
    NSString *dateString = @"";
    int interval = (int)[[NSDate date] timeIntervalSinceDate:date];
    if (interval < 0) {
        dateString = @"0m";
    } else if (interval < 3600) {
        dateString = [NSString stringWithFormat:@"%dm", interval / 60];
    } else if (interval < 86400) {
        dateString = [NSString stringWithFormat:@"%dh", interval / 3600];
    } else {
        dateString = [NSString stringWithFormat:@"%dd", interval / 86400];
    }
    
    [self dateLabel].text = dateString;
    
    // timer icon
    CGSize sz = [dateString sizeWithFont:[self dateLabel].font constrainedToSize:CGSizeMake(1000, 20)];
    CGPoint center = [self timer].center;
    center.x = CGRectGetMaxX([self dateLabel].frame) - sz.width - 15;
    [self timer].center = center;
    
    // status indicator
    [self indicator].hidden = ([data.status intValue] != NotificationStatusUnread);
}


@end
