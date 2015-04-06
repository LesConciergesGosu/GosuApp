//
//  ProfileFavoritePickerCell.h
//  Gosu
//
//  Created by dragon on 5/13/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProfileFavoritePickerCell;
@protocol ProfileFavoritePickerCellDelegate<NSObject>
- (void)profileFavoritePickerCell:(ProfileFavoritePickerCell *)cell pickCategory:(NSString *)category withItem:(NSString *)item;
@end

@interface ProfileFavoritePickerCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) IBOutlet UIButton *button;

@property (nonatomic) id<ProfileFavoritePickerCellDelegate> delegate;
@end
