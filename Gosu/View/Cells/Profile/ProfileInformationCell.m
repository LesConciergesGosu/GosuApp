//
//  ProfileInformationCell.m
//  Gosu
//
//  Created by dragon on 5/13/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "ProfileInformationCell.h"
#import "NSString+Drawing.h"

@implementation ProfileInformationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) resizeToFit
{
    
    CGSize size = [self.titleLabel sizeThatFits:CGSizeMake(120, 30)];
    
    CGRect frame1 = self.titleLabel.frame;
    frame1.size.width = size.width;
    self.titleLabel.frame = frame1;
    
    CGRect frame2 = self.detailLabel.frame;
    frame2.origin.x = CGRectGetMaxX(frame1) + 10;
    frame2.size.width = 274 - size.width;
    self.detailLabel.frame = frame2;
}

+ (CGFloat)heightForDetailText:(NSString *)detailText withTitle:(NSString *)title {
    
    UIFont *font = [UIFont systemFontOfSize:14];
    
    
    CGSize size = [title sizeWithFont:font fitToSize:CGSizeMake(120, 30)];
    
    CGSize size1 = [detailText sizeWithFont:font fitToSize:CGSizeMake(274 - size.width, 100)];
    
    CGFloat res = size1.height + 5 < 25 ? 25 : size1.height + 5;
    
    return res + 10;
}

@end
