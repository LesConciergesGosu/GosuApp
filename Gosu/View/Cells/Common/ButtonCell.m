//
//  ButtonCell.m
//  Gosu
//
//  Created by dragon on 5/12/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "ButtonCell.h"

@implementation ButtonCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)onButtonClicked:(id)sender {
    
    if (self.buttons)
    {
        [self.delegate buttonCell:self tappedButtonAtIndex:[self.buttons indexOfObject:sender]];
    }
    else
    {
        [self.delegate buttonCell:self tappedButtonAtIndex:0];
    }
}

@end
