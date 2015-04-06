//
//  MenuViewController.m
//  Gosu
//
//  Created by dragon on 3/19/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "MenuViewController.h"
#import "UIViewController+ViewDeck.h"
#import "SplashViewController.h"
#import "MainViewController.h"
#import "ProfileViewController.h"
#import "StatusViewController.h"
#import "AppDelegate.h"
#import "BadgeBarButtonItem.h"
#import "SideMenuCell.h"
#import "BadgeLabel.h"

#import "User+Extra.h"
#import "DataManager.h"

@interface SideMenu : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic) NSInteger action;

+ (instancetype) menuWithAction:(SideMenuAction)action;
@end

@implementation SideMenu

+ (instancetype) menuWithAction:(SideMenuAction)action {
    
    SideMenu *res = [[SideMenu alloc] init];
    
    res.action = action;
    switch (action) {
        case SideMenuActionHome:
            res.title = @"Home";
            break;
        case SideMenuActionJobBoard:
            res.title = @"Job Board";
            break;
        case SideMenuActionProfile:
            res.title = @"Profile";
            break;
        case SideMenuActionPayment:
            res.title = @"Payment";
            break;
        case SideMenuActionLogOut:
            res.title = @"Logout";
            break;
        default:
            res.title = @"Menu";
            break;
    }
    
    return res;
}

@end


@interface MenuViewController ()

@property (nonatomic, strong) NSArray *menus;
@property (nonatomic, strong) BadgeBarButtonItem *notificationItem;
@end

@implementation MenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customButton setFrame:CGRectMake(0, 0, 40, 40)];
    [customButton setImage:[UIImage imageNamed:@"icon_notifications.png"]
                  forState:UIControlStateNormal];
    [customButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [customButton addTarget:self
                     action:@selector(onNotifications:)
           forControlEvents:UIControlEventTouchUpInside];
    
    // Create and add our custom BBBadgeBarButtonItem
    BadgeBarButtonItem *barButtonItem = [[BadgeBarButtonItem alloc] initWithCustomUIButton:customButton];
    // Set a value for the badge
    barButtonItem.badgeOriginY = 0;
    barButtonItem.badgeOriginX = 14;
    
    // Add it as the leftBarButtonItem of the navigation bar
    self.navigationItem.leftBarButtonItem = barButtonItem;
    self.notificationItem = barButtonItem;
    
    
    [self updateBadgeNumber:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBadgeNumber:)
                                                 name:NotificationUpdatedUnreadMessageCounts
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBadgeNumber:)
                                                 name:NotificationNotificationListUpdated
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData:)
                                                 name:NotificationLoggedIn
                                               object:nil];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateBadgeNumber:(id)sender
{
    if ([User currentUser] != nil) {
        NSInteger badge = [[User currentUser] countOfUnreadNotifications];
        self.notificationItem.badgeValue = badge;
    } else {
        self.notificationItem.badgeValue = 0;
    }
    
    [self.tableView reloadData];
}

- (void) reloadData:(id)sender {
    
    if ([[User currentUser].userType intValue] == UserTypeCustomer) {
        self.menus = @[[SideMenu menuWithAction:SideMenuActionHome],
                       [SideMenu menuWithAction:SideMenuActionProfile],
                       [SideMenu menuWithAction:SideMenuActionPayment],
                       [SideMenu menuWithAction:SideMenuActionLogOut]];
    } else {
        self.menus = @[[SideMenu menuWithAction:SideMenuActionHome],
                       [SideMenu menuWithAction:SideMenuActionJobBoard],
                       [SideMenu menuWithAction:SideMenuActionProfile],
                       [SideMenu menuWithAction:SideMenuActionPayment],
                       [SideMenu menuWithAction:SideMenuActionLogOut]];
    }
    
    [self.tableView reloadData];
}

#pragma mark Actions

- (IBAction)onNotifications:(id)sender
{
    MainViewController *deckController = [AppDelegate sharedInstance].rootViewController;
    [deckController openViewControllerWithMenuAction:SideMenuActionNotification];
    [deckController closeLeftViewAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menus count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SideMenuCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"SideMenuCell"];
    
    if (indexPath.row < [self.menus count]) {
        
        SideMenu *menu = self.menus[indexPath.row];
        cell.titleLabel.text = menu.title;
        
        if (menu.action == SideMenuActionHome) {
            cell.badgeLabel.badgeValue = [[User currentUser] countOfTaskHasNewMessages];
        } else {
            cell.badgeLabel.badgeValue = 0;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row >= [self.menus count])
        return;
    
    SideMenu *menu = self.menus[indexPath.row];
    
    switch (menu.action) {
        case SideMenuActionHome:
        case SideMenuActionJobBoard:
        case SideMenuActionProfile:
        case SideMenuActionPayment:
        {
            MainViewController *deckController = [AppDelegate sharedInstance].rootViewController;
            [deckController openViewControllerWithMenuAction:menu.action];
            [deckController closeLeftViewAnimated:YES];
        }
            break;
        case SideMenuActionLogOut:
        {
            [[DataManager manager] logOut];
            
            MainViewController *deckController = [AppDelegate sharedInstance].rootViewController;
            [deckController closeLeftViewAnimated:YES];
            
            SplashViewController *splashVC = [self.storyboard instantiateViewControllerWithIdentifier:@"splashViewController"];
            UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:splashVC];
            navVC.navigationBarHidden = YES;
            [deckController presentViewController:navVC animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}


@end
