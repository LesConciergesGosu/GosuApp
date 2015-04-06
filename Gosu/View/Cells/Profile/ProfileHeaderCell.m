//
//  ProfileHeaderCell.m
//  Gosu
//
//  Created by dragon on 5/26/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "ProfileHeaderCell.h"

#import "User+Extra.h"
#import "UserProfile+Extra.h"

@implementation ProfileHeaderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) loadUser:(User *)user {
    
    int countOfCompletedTasks = 0;
    int countOfOngoingTasks = 0;
    int savedHours = 0;
    
    if (user.profile) {
        countOfCompletedTasks = [user.profile.countOfCompletedTasks intValue];
        countOfOngoingTasks = [user.profile.countOfOngoingTasks intValue];
        savedHours = [user.profile.savedHours intValue];
    }
    
    NSDictionary *greenAttr = @{NSForegroundColorAttributeName:APP_COLOR_GREEN};
    NSDictionary *grayAttr = @{NSForegroundColorAttributeName:APP_COLOR_TEXT_GRAY};
    
    NSString *string;
    NSMutableAttributedString *attrString;
    
    string = [NSString stringWithFormat:@"%d completed tasks", countOfCompletedTasks];
    attrString = [[NSMutableAttributedString alloc] initWithString:string attributes:grayAttr];
    [attrString addAttributes:greenAttr range:NSMakeRange(0, [string rangeOfString:@" "].location)];
    
    self.lblCompletedTasks.attributedText = attrString;
    
    string = [NSString stringWithFormat:@"%d ongoing tasks", countOfOngoingTasks];
    attrString = [[NSMutableAttributedString alloc] initWithString:string attributes:grayAttr];
    [attrString addAttributes:greenAttr range:NSMakeRange(0, [string rangeOfString:@" "].location)];
    
    self.lblOngoingTasks.attributedText = attrString;
    
    string = [NSString stringWithFormat:@"%d hours saved", savedHours];
    attrString = [[NSMutableAttributedString alloc] initWithString:string attributes:greenAttr];
    
    self.lblSavedHours.attributedText = attrString;
    
}

@end
