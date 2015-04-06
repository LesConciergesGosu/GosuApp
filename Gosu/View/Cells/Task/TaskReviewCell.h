//
//  TaskReviewCell.h
//  Gosu
//
//  Created by dragon on 3/28/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RoundImageView, GStarRating;
@interface TaskReviewCell : UICollectionViewCell

@property (nonatomic, weak) NSMutableDictionary *review;

@property (nonatomic, weak) IBOutlet RoundImageView *personPhotoView;
@property (nonatomic, weak) IBOutlet UILabel *personNameLabel;
@property (nonatomic, weak) IBOutlet GStarRating *ratingView;
@property (nonatomic, weak) IBOutlet UIButton *gosuToggleButton;
@end
