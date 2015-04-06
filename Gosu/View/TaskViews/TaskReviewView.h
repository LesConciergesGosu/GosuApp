//
//  TaskReviewView.h
//  Gosu
//
//  Created by dragon on 3/22/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "BlurModalView.h"

@class TaskReviewView;
@protocol TaskReviewViewDelegate <NSObject>

@optional
- (void) taskReviewView:(TaskReviewView *)view didDismissWithReviews:(NSArray *)reviews;

@end

@class RoundImageView;
@class GStarRating;
@class Task;
@interface TaskReviewView : BlurModalView<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *taskTitleLabel;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIButton *goButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) Task *task;
@property (weak) id<TaskReviewViewDelegate> delegate;

- (id) initWithParentView:(UIView *)parentView withTask:(Task *)task;
@end
