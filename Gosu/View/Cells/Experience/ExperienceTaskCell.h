//
//  ExperienceTaskCell.h
//  Gosu
//
//  Created by Dragon on 11/26/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ExperienceTaskCell;
@protocol ExperienceTaskCellDelegate <NSObject>

- (void)experienceTaskCell:(ExperienceTaskCell *)cell tappedButtonAtIndex:(NSInteger)index;
@end

@interface ExperienceTaskCell : UICollectionViewCell

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *buttons;
@property (nonatomic, strong) IBOutlet UIView *container;
@property (nonatomic, weak) IBOutlet UIView *viewType;
@property (nonatomic, weak) IBOutlet UIImageView *imvType;
@property (nonatomic, weak) IBOutlet UIView *viewTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblEmployeeName;
@property (nonatomic, weak) IBOutlet UIImageView *imvEmployeePhoto;

@property (nonatomic, weak) id<ExperienceTaskCellDelegate> delegate;
@end
