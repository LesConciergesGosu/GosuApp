//
//  ExperienceTaskCell.m
//  Gosu
//
//  Created by Dragon on 11/26/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "ExperienceTaskCell.h"

@implementation ExperienceTaskCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)onBubbleTapped:(id)sender
{
    if (self.buttons)
    {
        [self.delegate experienceTaskCell:self tappedButtonAtIndex:[self.buttons indexOfObject:sender]];
    }
    else
    {
        [self.delegate experienceTaskCell:self tappedButtonAtIndex:0];
    }
}

@end
