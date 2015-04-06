//
//  MainViewController.m
//  Gosu
//
//  Created by dragon on 3/19/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "MainViewController.h"
#import "StatusViewController.h"
#import "ProfileViewController.h"
#import "CardListViewController.h"
#import "JobBoardViewController.h"
#import "NotificationsViewController.h"
#import "UIViewController+ViewDeck.h"

@interface RestrictPanningDelegate:NSObject<UIGestureRecognizerDelegate>

@end

@implementation RestrictPanningDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

@end

@interface MainViewController ()

@property (strong) RestrictPanningDelegate *restrictPanningDelegate;
@property (strong) UINavigationController *statusNavController;
@end

@implementation MainViewController

- (id) initWithCoder:(NSCoder *)aDecoder
{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController *menuVC = [storyboard instantiateViewControllerWithIdentifier:@"menuNavViewController"];
    UIViewController *statusVC = [storyboard instantiateViewControllerWithIdentifier:@"statusNavController"];
    
    self = [super initWithCenterViewController:statusVC
                            leftViewController:menuVC];
    
    if (self) {
        self.restrictPanningDelegate = [[RestrictPanningDelegate alloc] init];
        self.statusNavController = (UINavigationController *)statusVC;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onLogOut:)
                                                     name:NotificationLoggedOut
                                                   object:nil];
    }
    
    return self;
}

- (void) onLogOut:(id)sender
{
    [self openViewControllerWithMenuAction:SideMenuActionHome];
}

- (UIViewController *)topViewController
{
    UIViewController *centerVC = [self centerController];
    
    if (centerVC.presentedViewController)
        return centerVC.presentedViewController;
    
    if ([centerVC isKindOfClass:[UINavigationController class]])
        return [(UINavigationController *)centerVC topViewController];
    
    return centerVC;
}

- (void) openViewControllerWithMenuAction:(SideMenuAction)index
{
    if (index == SideMenuActionHome) {
        
        if ([self centerController] != self.statusNavController) {
            [self setCenterController:self.statusNavController];
        }
        
    } else if (index == SideMenuActionJobBoard) {
        
        UIViewController *centerVC = [[self centerController] rootController];
        if (![centerVC isKindOfClass:[JobBoardViewController class]]) {
            UIViewController *jobBoardNavVC = [self.storyboard instantiateViewControllerWithIdentifier:@"jobBoardNavController"];
            [self setCenterController:jobBoardNavVC];
        }
        
    } else if (index == SideMenuActionProfile) {
        
        UIViewController *centerVC = [[self centerController] rootController];
        
        UINavigationController *profileNavVC;
        
        if (![centerVC isKindOfClass:[ProfileViewController class]]) {
            profileNavVC = (UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"profileNavController"];
            [self setCenterController:profileNavVC];
        }
        
    } else if (index == SideMenuActionPayment) {
        
        UIViewController *centerVC = [[self centerController] rootController];
        if (![centerVC isKindOfClass:[CardListViewController class]]) {
            UIViewController *profileNavVC = [self.storyboard instantiateViewControllerWithIdentifier:@"cardListNavController"];
            [self setCenterController:profileNavVC];
        }
        
    } else if (index == SideMenuActionNotification) {
        
        UIViewController *centerVC = [[self centerController] rootController];
        if (![centerVC isKindOfClass:[NotificationsViewController class]]) {
            UIViewController *notificationNavVC = [self.storyboard instantiateViewControllerWithIdentifier:@"notificationNavController"];
            [self setCenterController:notificationNavVC];
        }
        
    }
}

- (void) openTaskReviewModalForTask:(Task *)task
{
    // open task review modal with blur background.
    TaskReviewView *reviewView =
        [[TaskReviewView alloc] initWithParentView:self.centerController.view withTask:task];
    [reviewView setDelegate:self];
    [reviewView show];
    
    //disable the gesture of sliding menu
    self.panningGestureDelegate = self.restrictPanningDelegate;
}

- (void) taskReviewView:(TaskReviewView *)view didDismissWithReviews:(NSArray *)reviews
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationReviewedTask object:nil];
    self.panningGestureDelegate = nil;
}

@end
