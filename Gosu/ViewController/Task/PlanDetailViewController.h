//
//  PlanDetailViewController.h
//  Gosu
//
//  Created by Dragon on 11/13/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlanDetailViewController : UIViewController
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UIButton *btnTabActive;
@property (nonatomic, strong) IBOutlet UIButton *btnTabCompleted;
@end
