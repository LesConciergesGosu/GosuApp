//
//  ButtonCell.h
//  Gosu
//
//  Created by dragon on 5/12/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ButtonCell;
@protocol ButtonCellDelegate <NSObject>

- (void)buttonCellButtonTapped:(ButtonCell *)cell;

@end

@interface ButtonCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIButton *button;
@property (strong) NSIndexPath *indexPath;
@property (weak) id<ButtonCellDelegate> delegate;
@end
