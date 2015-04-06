//
//  PickerInputFieldCell.m
//  Gosu
//
//  Created by dragon on 6/3/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "PickerInputFieldCell.h"

@implementation PickerInputFieldCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.values count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (row < [self.values count])
        return self.values[row];
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *value = [self pickerView:pickerView titleForRow:row forComponent:component];
    [self.delegate baseInputFieldCell:self valueChanged:value];
}

@end
