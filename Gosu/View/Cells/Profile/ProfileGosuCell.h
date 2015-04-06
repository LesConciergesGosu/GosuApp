//
//  ProfileGosuCell.h
//  Gosu
//
//  Created by dragon on 5/13/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProfileGosuCell;
@protocol ProfileGosuCellDelegate <NSObject>

- (void) profileGosuCellRemove:(ProfileGosuCell *)cell;

@end

@class GosuRelation;
@interface ProfileGosuCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *photoView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIButton *removeButton;

@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) id<ProfileGosuCellDelegate> delegate;

- (void)setData:(GosuRelation *)data;
@end
