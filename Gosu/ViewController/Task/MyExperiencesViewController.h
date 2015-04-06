//
//  MyExperiencesViewController.h
//  Gosu
//
//  Created by dragon on 3/19/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyExperiencesViewController : UIViewController

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UIButton *btnTabItinerary;
@property (nonatomic, strong) IBOutlet UIButton *btnTabPending;

@end
