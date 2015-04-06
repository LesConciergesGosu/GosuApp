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
    [self.delegate buttonCellButtonTapped:self];
}

@end
