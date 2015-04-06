//
//  RemovableCell.h
//  Gosu
//
//  Created by dragon on 6/6/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RemovableCell;
@protocol RemovableCellDelegate <NSObject>
@optional
- (BOOL)shouldRemoveableCellRemoved:(RemovableCell *)cell;

@end

@interface RemovableCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIView *cellView;
@property (weak) id<RemovableCellDelegate> delegate;
@property (nonatomic) BOOL swipeToDeleteEnabled;

// reserved
@property (nonatomic, weak) id data;
// reserved
@property (nonatomic, strong) NSIndexPath *indexPath;

@end
