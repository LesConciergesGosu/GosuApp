//
//  UIViewController+ViewDeck.m
//  Gosu
//
//  Created by dragon on 3/19/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "UIViewController+ViewDeck.h"

@implementation UIViewController (ViewDeck)


- (IIViewDeckController *)deckController
{
    
    if (self.parentViewController)
    {
        if ([self.parentViewController isKindOfClass:[IIViewDeckController class]])
            return (IIViewDeckController *)self.parentViewController;
    }
    
    return nil;
}

- (UIViewController *)rootController
{
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)self viewControllers][0];
    }
    
    return self;
}

@end
