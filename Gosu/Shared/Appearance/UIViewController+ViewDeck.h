//
//  UIViewController+ViewDeck.h
//  Gosu
//
//  Created by dragon on 3/19/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ViewDeck/IIViewDeckController.h>

@interface UIViewController (ViewDeck)

- (IIViewDeckController *)deckController;
- (UIViewController *)rootController;
@end
