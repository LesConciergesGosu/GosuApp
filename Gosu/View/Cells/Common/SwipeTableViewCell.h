//
//  SwipeTableViewCell.h
//  Gosu
//
//  Created by Dragon on 10/12/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    SwipeTypeNone,
    SwipeTypeRight,
    SwipeTypeLeft
} SwipeType;

@class SwipeTableViewCell;
@protocol SwipeTableViewCellDelegate <NSObject>
@optional
- (BOOL)swipeCellShouldStartSwipe:(SwipeTableViewCell *)cell;
- (void)swipeCell:(SwipeTableViewCell *)cell swipeTypeChangedFrom:(SwipeType)from to:(SwipeType)to;
- (void)swipeCell:(SwipeTableViewCell *)cell triggeredSwipeWithType:(SwipeType)type;

@end


@interface SwipeTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIView *cellView;
@property (nonatomic) BOOL hasSwipe;
@property (nonatomic) CGFloat buttonWidth;
@property (nonatomic, weak) id<SwipeTableViewCellDelegate> delegate;
- (SwipeType) swipeType;
- (void) closeSwipe;
@end
