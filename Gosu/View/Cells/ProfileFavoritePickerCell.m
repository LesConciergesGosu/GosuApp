//
//  ProfileFavoritePickerCell.m
//  Gosu
//
//  Created by dragon on 5/13/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "ProfileFavoritePickerCell.h"

@interface ProfileFavoritePickerCell()<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) NSArray *favoriteItems;
@end

@implementation ProfileFavoritePickerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    self.favoriteItems = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"favoriteItems.plist" ofType:nil]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onAdd:(id)sender
{
    NSInteger categoryRow = [self.pickerView selectedRowInComponent:0];
    NSInteger itemRow = [self.pickerView selectedRowInComponent:1];
    
    NSDictionary *category = self.favoriteItems[categoryRow];
    
    [self.delegate profileFavoritePickerCell:self pickCategory:category[@"title"] withItem:category[@"items"][itemRow]];
}

#pragma mark Picker View

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0)
        return [self.favoriteItems count];
    
    NSDictionary *category = self.favoriteItems[[pickerView selectedRowInComponent:0]];
    return [category[@"items"] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (component == 0)
    {
        NSDictionary *category = self.favoriteItems[row];
        return category[@"title"];
    }
    
    NSDictionary *category = self.favoriteItems[[pickerView selectedRowInComponent:0]];
    return category[@"items"][row];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        [pickerView reloadComponent:1];
    }
}

@end
