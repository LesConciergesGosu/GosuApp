//
//  RightRootViewController.m
//  Gosu
//
//  Created by dragon on 6/23/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "RightRootViewController.h"
#import "UIViewController+ViewDeck.h"
#import "BadgeBarButtonItem.h"
#import "User+Extra.h"

@interface RightRootViewController ()

@property (nonatomic, strong) BadgeBarButtonItem *menuButton;
@end

@implementation RightRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customButton setFrame:CGRectMake(0, 0, 40, 40)];
    [customButton setImage:[UIImage imageNamed:@"menu_icon.png"]
                  forState:UIControlStateNormal];
    [customButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [customButton addTarget:self
                     action:@selector(onShowMenu:)
           forControlEvents:UIControlEventTouchUpInside];
    
    // Create and add our custom BBBadgeBarButtonItem
    self.menuButton = [[BadgeBarButtonItem alloc] initWithCustomUIButton:customButton];
    // Set a value for the badge
    self.menuButton.badgeOriginY = 0;
    self.menuButton.badgeOriginX = 12;
    
    // Add it as the leftBarButtonItem of the navigation bar
    self.navigationItem.leftBarButtonItem = self.menuButton;
    
    [self updateBadgeNumber:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBadgeNumber:)
                                                 name:NotificationUpdatedUnreadMessageCounts
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBadgeNumber:)
                                                 name:NotificationNotificationListUpdated
                                               object:nil];
}

- (UIBarButtonItem *)menuBarButtonItem
{
    return self.menuButton;
}

- (void) updateBadgeNumber:(id)sender
{
    if ([User currentUser] != nil) {
        NSInteger badge = [[User currentUser] countOfUnreadNotifications];
        badge += [[User currentUser] countOfTaskHasNewMessages];
        self.menuButton.badgeValue = badge;
    } else {
        self.menuButton.badgeValue = 0;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onShowMenu:(id)sender
{
    [self.navigationController.deckController toggleLeftViewAnimated:YES];
}

@end
