//
//  StatusBarViewController.m
//  Gosu
//
//  Created by Dragon on 10/27/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "StatusBarViewController.h"

@interface StatusBarViewController ()

@end

@implementation StatusBarViewController

- (UIViewController *)keyWindowRootViewController {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIWindow *ourWindow = [[self view] window];
    
    if (keyWindow != ourWindow) {
        return [keyWindow rootViewController];
    }
    
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        if (window != ourWindow)
            return [window rootViewController];
    }
    
    return nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [[self keyWindowRootViewController] shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (BOOL)shouldAutorotate
{
    return [[self keyWindowRootViewController] shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [[self keyWindowRootViewController] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [[self keyWindowRootViewController] preferredInterfaceOrientationForPresentation];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [[UIApplication sharedApplication] statusBarStyle];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end
