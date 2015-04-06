//
//  ExperienceTaskTableCell.h
//  Gosu
//
//  Created by Dragon on 11/27/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ExperienceTaskTableCell;
@protocol ExperienceTaskTableCellDelegate <NSObject>

- (void)experienceTaskTableCell:(id)cell tappedButtonAtIndex:(NSInteger)index;

@optional
- (NSInteger)numberOfRecommendationsForExperienceTaskTableCell:(id)cell;
- (UICollectionViewCell *)experienceTaskTableCell:(id)cell collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface ExperienceTaskTableCell : UITableViewCell

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *buttons;
@property (nonatomic, strong) IBOutlet UIView *container;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *colorViews;
@property (nonatomic, weak) IBOutlet UIImageView *imvType;
@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblDesc;

@property (nonatomic, strong) IBOutlet UICollectionView *cltRecommendations;

@property (nonatomic, weak) id<ExperienceTaskTableCellDelegate> delegate;
@property (nonatomic ,weak) id data;
@end
