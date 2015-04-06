//
//  CardListViewController.h
//  Gosu
//
//  Created by dragon on 3/29/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RightRootViewController.h"


@class CardListViewController;
@class PCreditCard;
@protocol CardSelectionDelegate <NSObject>

@optional
- (void)cardListViewController:(CardListViewController *)viewController didFinishWithCard:(PCreditCard *)card;
- (void)cardListViewControllerDidCancel:(CardListViewController *)viewController;

@end

@interface CardListViewController : RightRootViewController

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@end
