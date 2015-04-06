//
//  DashboardViewController.m
//  Gosu
//
//  Created by Dragon on 9/30/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "DashboardViewController.h"
#import "Offer+Extra.h"
#import "User+Extra.h"
#import "Experience+Extra.h"
#import "SwipeTableViewCell.h"
#import "DashboardCell.h"

#import "UIViewController+ViewDeck.h"
#import "CreateExperienceViewController.h"
#import "DashboardTaskPopup.h"
#import "LocationManager.h"
#import "DataManager.h"
#import "NSDate+Extra.h"
#import "NSString+Task.h"
#import "SVProgressHUD.h"
#import "ProfileViewController.h"
#import "PushModalTransitionAnimator.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <AFNetworking/UIButton+AFNetworking.h>

@interface DashboardViewController ()<UITableViewDataSource, UITableViewDelegate, SwipeTableViewCellDelegate, DashboardCellDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, DashboardTaskPopupDelegate, CreateExperienceDelegate, UIViewControllerTransitioningDelegate>
{
    NSString *oldCity;
}

@property (nonatomic, strong) NSMutableArray *offers;
@property (nonatomic, weak) SwipeTableViewCell *swipingCell;
@property (nonatomic, strong) DashboardTaskPopup *taskPopup;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation DashboardViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    oldCity = nil;
    self.view.backgroundColor = APP_COLOR_NAV_TINIT;
//    self.navBar.backgroundColor = APP_COLOR_NAV_TINIT;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = view;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"BACK" style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCityChanged:) name:kCityDidChangeNotificationKey object:nil];
    
    self.welcomeView.hidden = YES;
    self.offerNotifyView.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(afterLogin:)
                                                 name:NotificationLoggedIn
                                               object:nil];
    [self afterLogin:nil];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(onRefrehOrders:) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:self.refreshControl];
    
    CGRect bounds = self.refreshControl.bounds;
    self.refreshControl.bounds = CGRectMake(bounds.origin.x, bounds.origin.y - 130, bounds.size.width, bounds.size.height);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    if ([self.navigationController deckController])
        [[self.navigationController deckController] setPanningGestureDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.navigationController deckController] && [self.navigationController deckController].panningGestureDelegate == self)
        [[self.navigationController deckController] setPanningGestureDelegate:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onRefrehOrders:(id)sender
{
    [Offer loadMyOffersWithCompletionHandler:^(BOOL success, NSString *errorDesc) {
        if (success)
            [self onOffersUpdated:nil];
        
        [self.refreshControl endRefreshing];
    }];
}

- (void)afterLogin:(id)sender
{
    
    [self updateBadgeNumber:nil];
    if (![User currentUser])
        return;
    
    [self onCityChanged:nil];
    [self onOffersUpdated:nil];
    
    User *user = [User currentUser];
    
    self.titleLabel.text = user.firstName ? [NSString stringWithFormat:@"HELLO %@", [[user firstName] uppercaseString]] : @"HELLO";
    self.photoView.image = [UIImage imageNamed:@"buddy"];
    NSString *photoUrlString = [user photo];
    if (photoUrlString)
    {
        [[DataManager manager] loadImageURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:photoUrlString]] handler:^(UIImage *image) {
            if (image)
                self.photoView.image = image;
        }];
    }
    
    if (![self.refreshControl isRefreshing])
    {
        [self.refreshControl beginRefreshing];
        
        [Offer loadMyOffersWithCompletionHandler:^(BOOL success, NSString *errorDesc) {
            if (success)
                [self onOffersUpdated:nil];
            
            [self.refreshControl endRefreshing];
        }];
    }
}

- (void)onCityChanged:(id)sender
{
    
    if (![User currentUser])
        return;
    
    LocationManager *locationManager = [LocationManager manager];
    
    NSString *city = [User currentUser].city ?: locationManager.currentCity;
    
    if (city)
    {
        
        self.welcomeView.hidden = NO;
        self.welcomePin.hidden = NO;
        self.welcomeLabel.text = @"WELCOME TO";
        
        CGRect frame = self.welcomeLabel2.frame;
        frame.origin.x = 14;
        self.welcomeLabel2.frame = frame;
        self.welcomeLabel2.text = [NSString stringWithFormat:@"%@", city];
        
        if ([city isEqualToString:oldCity])
            return;
        
        oldCity = [city copy];
        
        self.profileBGView.image = nil;
        
        NSURL *url = nil;
        if ([[city lowercaseString] hasPrefix:@"new york"])
        {
            url = [NSURL URLWithString:@"http://upload.wikimedia.org/wikipedia/commons/5/52/New_York_Midtown_Skyline_at_night_-_Jan_2006_edit1.jpg"];
        }
        else if ([[city lowercaseString] hasPrefix:@"san francisco"])
        {
            url = [NSURL URLWithString:@"http://beauty-places.com/wp-content/uploads/2012/10/Golden-Gate-Bridge-5o-Clock-Wallpaper.jpg"];
        }
        else
        {
            url = [NSURL URLWithString:@"http://upload.wikimedia.org/wikipedia/commons/5/52/New_York_Midtown_Skyline_at_night_-_Jan_2006_edit1.jpg"];
        }
        
        if (url)
        {
            [self.profileBGView setImageWithURL:url];
        }
    }
    else
    {
        self.welcomeView.hidden = NO;
        self.welcomePin.hidden = YES;
        self.welcomeLabel.text = @"WELCOME";
        
        CGRect frame = self.welcomeLabel2.frame;
        frame.origin.x = 0;
        self.welcomeLabel2.frame = frame;
        self.welcomeLabel2.text = @"";
    }
}

- (void)onOffersUpdated:(id)sender
{
    if (![User currentUser])
        return;
    
    self.offers = [[Offer fetchOffers] mutableCopy];
    [self.tableView reloadData];
    if ([self.offers count] > 0)
        self.offerNotifyView.hidden = [self.offers count] == 0;
}

#pragma mark Overriden of RightRootViewController
- (void) updateBadgeNumber:(id)sender
{
    if ([User currentUser] != nil) {
        NSInteger badge = [[User currentUser] countOfUnreadNotifications];
        badge += [[User currentUser] countOfTaskHasNewMessages];
        self.menuBadgeLabel.badgeValue = badge;
    } else {
        self.menuBadgeLabel.badgeValue = 0;
    }
}

#pragma mark Side Menu Gesture Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panner
{
    return NO;
}

#pragma mark Actions
- (IBAction)showRadialPopup:(id)sender
{
    if (self.taskPopup == nil)
    {
        self.taskPopup = [DashboardTaskPopup taskPopupWithNavigationController:self.navigationController];
        self.taskPopup.delegate = self;
    }
    
    self.popupButton.hidden = YES;
    [self.taskPopup presentAnimated:YES screenshot:self.navigationController.view completion:nil];
    self.popupButton.hidden = NO;
}

- (IBAction)goUserProfile:(id)sender
{
    ProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    vc.noMenu = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
    
}

#pragma mark Table View

- (void) closeSwipe:(id)sender
{
    if (self.swipingCell)
        [self.swipingCell closeSwipe];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self closeSwipe:nil];
}

- (BOOL)swipeCellShouldStartSwipe:(SwipeTableViewCell *)cell
{
    if (self.swipingCell == nil || self.swipingCell == cell)
        return YES;
    
    
    [self closeSwipe:nil];
    
    return NO;
}

- (void)swipeCell:(SwipeTableViewCell *)cell swipeTypeChangedFrom:(SwipeType)from to:(SwipeType)to
{
    if (to != SwipeTypeNone)
    {
        self.swipingCell = cell;
    }
    else if (self.swipingCell == cell)
    {
        self.swipingCell = nil;
    }
}

- (void)swipeCell:(SwipeTableViewCell *)cell triggeredSwipeWithType:(SwipeType)type
{
    if (self.swipingCell == cell && type == SwipeTypeNone)
    {
        self.swipingCell = nil;
    }
    
    if (self.swipingCell != cell && type != SwipeTypeNone) {
        self.swipingCell = cell;
    }
}

- (void)dashboardCellDismiss:(DashboardCell *)cell
{
    if (self.swipingCell)
    {
        self.swipingCell = nil;
    }
    
    NSInteger index = [self.tableView indexPathForCell:cell].row;
    
    Offer *offer = self.offers[index];
    NSManagedObjectID *objectID = offer.objectID;
    NSManagedObjectContext *context = offer.managedObjectContext;
    [context performBlock:^{
        Offer *offer = (Offer *)[context objectWithID:objectID];
        offer.archived = @(YES);
        [context saveRecursively];
    }];
    
    [self.offers removeObjectAtIndex:index];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)dashboardCellRemindLater:(DashboardCell *)cell
{
    
    if (self.swipingCell == cell)
    {
        [self closeSwipe:nil];
        self.swipingCell = nil;
    }
}

- (void)dashboardSelected:(DashboardCell *)cell
{
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (indexPath)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Would you like to take this offer?" message:nil delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        alertView.tag = indexPath.row + 1000;
        [alertView show];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.offers count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Offer *offer = self.offers[indexPath.row];
    return [offer.category integerValue] == OfferTypeGift ? 85 : 155;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Offer *offer = self.offers[indexPath.row];
    
    DashboardCell *cell;
    
    if ([offer.category integerValue] == OfferTypeGift)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"GiftCard"];
        cell.colorView.backgroundColor = [offer typeColor];
        cell.descLabel.text = offer.offer;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM\ndd"];
        cell.timeLabel.text = [formatter stringFromDate:offer.startDate];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCard"];
        cell.descLabel.text = offer.offer;
        cell.placeLabel.text = [offer.benefit stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (offer.startTime && offer.endTime)
        {
            NSTimeInterval startTime = (long)([offer.localTimeZone integerValue] + [offer.startTime doubleValue]);
            NSTimeInterval endTime = (long)([offer.localTimeZone integerValue] + [offer.endTime doubleValue]);
            cell.timeLabel.text = [NSString stringWithFormat:@"@ %@ - %@", [NSDate timeStringFromTimeInterval:startTime], [NSDate timeStringFromTimeInterval:endTime]];
        }
        else if (offer.startTime)
        {
            NSTimeInterval time = (long)([offer.localTimeZone integerValue] + [offer.startTime doubleValue]);
            cell.timeLabel.text = [NSString stringWithFormat:@"@ %@", [NSDate timeStringFromTimeInterval:time]];
        }
        else
        {
            cell.timeLabel.text = @"";
        }
        
        cell.colorView.backgroundColor = [offer typeColor];
        
        if (offer.photoUrl)
        {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:offer.photoUrl]];
            
            UIImage *image = [[UIImageView sharedImageCache] cachedImageForRequest:request];
            
            if (image)
            {
                cell.bgImageView.image = image;
            }
            else
            {
                [cell.bgImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    DashboardCell *cellToUpdate = (DashboardCell *)[tableView cellForRowAtIndexPath:indexPath];
                    cellToUpdate.bgImageView.image = image;
                    
                    
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    
                }];
            }
        }
    }
    cell.contentView.backgroundColor = [offer typeColor];
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag >= 1000)
    {
        if (alertView.firstOtherButtonIndex == buttonIndex)
        {
            NSInteger index = alertView.tag - 1000;
            
            if (index < [self.offers count])
            {
                Offer *offer = self.offers[index];
                
                NSManagedObjectID *objectID = offer.objectID;
                NSManagedObjectContext *context = offer.managedObjectContext;
                [context performBlockAndWait:^{
                    Offer *offer = (Offer *)[context objectWithID:objectID];
                    offer.archived = @(YES);
                    [context saveRecursively];
                }];
                
                [self.offers removeObjectAtIndex:index];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                GCreateObjectBlock successBlock = ^(BOOL success, id object, NSString *errorDesc) {
                    
                    [SVProgressHUD dismiss];
                    if (success) {
                        [SVProgressHUD showSuccessWithStatus:@""];
                        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationCreatedNewTask object:object];
                    } else {
                        [[[UIAlertView alloc] initWithTitle:@"Warning"
                                                    message:errorDesc
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil] show];
                    }
                };
                
                [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
                
                [Experience createExperienceWithOffer:offer completion:successBlock];
            }
        }
    }
}

- (void)dashboardTaskPopup:(DashboardTaskPopup *)popup didDismissWithTypes:(NSArray *)types
{
    
    CreateExperienceViewController *vc = [CreateExperienceViewController createExperienceViewControllerWithTypes:types];
    vc.taskDelegate = self;
    if (vc != nil)
    {
        vc.modalPresentationStyle = UIModalPresentationCustom;
        vc.transitioningDelegate = self;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)createExperienceViewController:(CreateExperienceViewController *)vc didFailWithError:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)createExperienceViewController:(CreateExperienceViewController *)vc didFinishWithResult:(BOOL)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createExperienceViewControllerDidCancel:(CreateExperienceViewController *)vc
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    PushModalTransitionAnimator *animator = [PushModalTransitionAnimator new];
    animator.presenting = YES;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    PushModalTransitionAnimator *animator = [PushModalTransitionAnimator new];
    animator.presenting = NO;
    return animator;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

