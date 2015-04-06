//
//  TextInputFieldCell.m
//  Gosu
//
//  Created by dragon on 6/3/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "TextInputFieldCell.h"

@implementation TextInputFieldCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)onValueChanged:(id)sender
{
    [self.delegate baseInputFieldCell:self valueChanged:self.textField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.delegate baseInputFieldCell:self valueChanged:self.textField.text];
}

@end
