//
//  StatusViewController.h
//  Gosu
//
//  Created by dragon on 3/19/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RightRootViewController.h"

/**
 Main screen - status view
 */
@interface StatusViewController : RightRootViewController

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UIView *bottomBar;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@end
