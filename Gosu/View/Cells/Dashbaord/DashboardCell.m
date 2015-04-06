//
//  DashboardCell.m
//  Gosu
//
//  Created by Dragon on 10/12/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "DashboardCell.h"

@implementation DashboardCell


- (void)prepareForReuse
{
    [super prepareForReuse];
    
    if (self.bgImageView)
        self.bgImageView.image = nil;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)onDismiss:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(dashboardCellDismiss:)])
    {
        [self.delegate dashboardCellDismiss:self];
    }
}

- (IBAction)onRemindMeLater:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(dashboardCellRemindLater:)])
    {
        [self.delegate dashboardCellRemindLater:self];
    }
}

- (IBAction)onSelect:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(dashboardSelected:)])
    {
        [self.delegate dashboardSelected:self];
    }
}

@end
