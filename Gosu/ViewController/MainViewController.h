//
//  MainViewController.h
//  Gosu
//
//  Created by dragon on 3/19/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ViewDeck/IIViewDeckController.h>
#import "TaskReviewView.h"
/**
 Deck view controller contains the left side menu & main contnet view.
 */



@interface MainViewController : IIViewDeckController<TaskReviewViewDelegate, UIGestureRecognizerDelegate>

- (UIViewController *)topViewController;

- (void) openViewControllerWithMenuAction:(SideMenuAction)action;
- (void) openTaskReviewModalForTask:(Task *)task;
@end
