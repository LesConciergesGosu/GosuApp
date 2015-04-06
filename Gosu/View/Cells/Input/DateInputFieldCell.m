//
//  DateInputFieldCell.m
//  Gosu
//
//  Created by dragon on 6/3/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "DateInputFieldCell.h"

@implementation DateInputFieldCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)onDateChanged:(id)sender
{
    [self.delegate baseInputFieldCell:self valueChanged:self.datePicker.date];
}

@end
