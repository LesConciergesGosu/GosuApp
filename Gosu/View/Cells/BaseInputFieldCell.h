//
//  BaseInputFieldCell.h
//  Gosu
//
//  Created by dragon on 6/3/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BaseInputFieldCell;
@protocol BaseInputFieldCellDelegate <NSObject>
- (void)baseInputFieldCell:(BaseInputFieldCell *)cell valueChanged:(id)newValue;
@end

@interface BaseInputFieldCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (weak) id<BaseInputFieldCellDelegate> delegate;

@end
