//
//  PlanDetailViewController.m
//  Gosu
//
//  Created by dragon on 3/19/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "PlanDetailViewController.h"
#import "UIViewController+ViewDeck.h"
#import "TaskCollectionViewCell.h"
#import "TaskCustomerCell.h"
#import "TaskMessageViewController.h"
#import "TaskDetailViewController.h"
//#import "CreateTaskViewController.h"
//#import "NewTaskViewController.h"
#import "CustomAlertView.h"
#import "CustomActionSheet.h"
#import "DashboardTaskPopup.h"
#import "AppDelegate.h"

#import <SVProgressHUD/SVProgressHUD.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

#import "User+Extra.h"
#import "Task+Extra.h"

#import "PFUser+Extra.h"
#import "NSString+Task.h"

#define STATUS_ACTIONSHEET_EMPOLYEE_ASSIGNED 10
#define STATUS_ACTIONSHEET_EMPOLYEE_DELIVERED 11
#define STATUS_ACTIONSHEET_CUSTOMER_FINISHED 21
#define STATUS_ACTIONSHEET_CUSTOMER_OPEN 20

typedef NS_ENUM(NSInteger, MyTasksTabIndex){
    MyTasksTabIndexActive,
    MyTasksTabIndexCompleted
};

@interface PlanDetailViewController ()<UICollectionViewDataSource,
UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIActionSheetDelegate, TaskCustomerCellDelegate, DashboardTaskPopupDelegate>
{
    MyTasksTabIndex currentTabIndex;
    CGFloat screenWidth;
}

@property (nonatomic, strong) DashboardTaskPopup *taskPopup;
@property (nonatomic, strong) NSArray *tasks;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation PlanDetailViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)] ) {
        [self.navigationController interactivePopGestureRecognizer].enabled = NO;
    }
    
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    
    currentTabIndex = MyTasksTabIndexActive;
    self.btnTabActive.selected = YES;
    self.btnTabCompleted.selected = NO;
    
    
    // add refresh control to the collection view
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor grayColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshControlValueChanged:)
                  forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    [self.collectionView setAlwaysBounceVertical:YES];
    
    [self afterLogin:nil];
    
    // add notification observer
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(afterLogin:)
                                                 name:NotificationLoggedIn
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData:)
                                                 name:NotificationLoadNewTask
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData:)
                                                 name:NotificationCreatedNewTask
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadView:)
                                                 name:NotificationRefreshTaskListView
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadLocalData:)
                                                 name:NotificationUpdatedUnreadMessageCounts
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadView:)
                                                 name:NotificationMyGosuListUpdated
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    if ([PFUser currentUser])
    {
        [self reloadLocalData:nil];
    }
}

#pragma mark Notification Selectors

- (void) reloadView:(id)sender
{
    [self.collectionView reloadData];
}

- (void) afterLogin:(id)sender
{
    
    //    User *user = [User currentUser];
    //
    //    if (![[user tutorialInstance].createTask boolValue]) {
    //        [user tutorialInstance].createTask = @(YES);
    //        [self onAddTask:nil];
    //
    //        if ([user.managedObjectContext hasChanges]) {
    //            [user.managedObjectContext saveRecursively];
    //        }
    //    }
    
    [self reloadLocalData:nil];
}

- (void) reloadData:(id)sender
{
    if ([self.refreshControl isRefreshing])
        return;
    
    [self.collectionView reloadData];
    [self refreshControlValueChanged:nil];
}


- (void) reloadLocalData:(id)sender {
    
    if (currentTabIndex == MyTasksTabIndexActive)
        self.tasks = [[User currentUser] fetchOpenTasksWithLimit:0];
    else
        self.tasks = [[User currentUser] fetchFinishedTasksWithLimit:0];
    
    [self.collectionView reloadData];
}

#pragma mark Actions

- (void) refreshControlValueChanged:(id)sender
{
    [self.refreshControl beginRefreshing];
    
    __weak PlanDetailViewController *wself = self;
    
    NSArray *statusArray = nil;
    
    if (currentTabIndex == MyTasksTabIndexActive)
    {
        statusArray = @[@(TaskStatusCreated), @(TaskStatusAssigned)];
    }
    else
    {
        statusArray = @[@(TaskStatusFinished), @(TaskStatusReviewed)];
    }
    
    [Task loadMyTasksWithStatus:statusArray CompletionHandler:^(BOOL success, NSString *errorDesc) {
        PlanDetailViewController *sself = wself;
        if (success && sself) {
            [sself.refreshControl endRefreshing];
            [sself reloadLocalData:nil];
        } else if (errorDesc) {
            DLog(@"failed to pull task with an error : %@", errorDesc);
        }
    }];
}

- (IBAction)onSwitchStatus:(UIButton *)sender
{
    
    if (sender == self.btnTabActive &&
        currentTabIndex != MyTasksTabIndexActive)
    {
        currentTabIndex = MyTasksTabIndexActive;
        self.btnTabActive.selected = YES;
        self.btnTabCompleted.selected = NO;
    }
    else if (sender == self.btnTabCompleted &&
             currentTabIndex != MyTasksTabIndexCompleted)
    {
        currentTabIndex = MyTasksTabIndexCompleted;
        self.btnTabActive.selected = NO;
        self.btnTabCompleted.selected = YES;
    }
    else
    {
        return;
    }
    
    [self reloadLocalData:nil];
}

- (IBAction)showRadialPopup:(id)sender
{
    if (self.taskPopup == nil)
    {
        self.taskPopup = [DashboardTaskPopup taskPopupWithNavigationController:self.navigationController];
        self.taskPopup.delegate = self;
    }
    
    [self.taskPopup presentAnimated:YES screenshot:self.navigationController.view completion:nil];
}

#pragma mark Collection View

- (void)taskCustomerCellMessages:(TaskCustomerCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    Task *task = self.tasks[indexPath.item];
    [self performSegueWithIdentifier:@"Messages" sender:task];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Task *task = self.tasks[indexPath.item];
    
    if (task.type)
    {
        if ([task.type isEqualToString:TASK_TYPE_FLIGHT] ||
            [task.type isEqualToString:TASK_TYPE_ACCOMODATION])
        {
            return CGSizeMake(screenWidth, 258);
        }
    }
    
    return CGSizeMake(screenWidth, 228);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self tasks].count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)aCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell *res = nil;
    
    Task *task = self.tasks[indexPath.item];
    
    if (task.type)
    {
        
        NSString *reuseIdentifier = nil;
        
        if (task.type2 && [task.type2 isEqualToString:TASK_TYPE_FLIGHT])
            reuseIdentifier = @"FlightCell";
        else if ([task.type isEqualToString:TASK_TYPE_ACCOMODATION])
            reuseIdentifier = @"AccomodationCell";
        else
            reuseIdentifier = @"CommonCell";
        
        TaskCustomerCell *cell = (TaskCustomerCell *)
        [aCollectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];;
        cell.contentView.frame = cell.bounds;
        cell.delegate = self;
        [cell setTask:self.tasks[indexPath.item]];
        
        if (task.photoUrl)
        {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:task.photoUrl]];
            
            UIImage *image = [[UIImageView sharedImageCache] cachedImageForRequest:request];
            
            if (image)
            {
                cell.topImageView.image = image;
            }
            else
            {
                [cell.topImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    TaskCustomerCell *cellToUpdate = (TaskCustomerCell *)[aCollectionView cellForItemAtIndexPath:indexPath];
                    cellToUpdate.topImageView.image = image;
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    
                }];
            }
        }
        
        res = cell;
    }
    
    if (res == nil)
    {
        TaskCollectionViewCell *cell = (TaskCollectionViewCell *)
        [aCollectionView dequeueReusableCellWithReuseIdentifier:@"FlightCell" forIndexPath:indexPath];
        cell.contentView.frame = cell.bounds;
        [cell setTask:self.tasks[indexPath.item]];
        
        res = cell;
    }
    
    return res;
}

- (void)collectionView:(UICollectionView *)aCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [aCollectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (indexPath.item < [self tasks].count)
    {
        Task *task = self.tasks[indexPath.item];
        
        if ([task isFault]) {
            DLog(@"Unexpected excpetion : task is fault : %@", task);
            return;
        }
        
        [self performSegueWithIdentifier:@"TaskDetail" sender:task];
        /*
         if (task.customer == [User currentUser]) {
         // customer - task owner
         
         if (task.customer != nil) {
         
         if ([task.status intValue] == TaskStatusFinished) {
         // task has been delivered, not reviewed yet.
         CustomActionSheet *actionSheet =
         [[CustomActionSheet alloc] initWithTitle:nil
         delegate:self
         cancelButtonTitle:@"Cancel"
         destructiveButtonTitle:@"Messages"
         otherButtonTitles:@"Rate the employee", nil];
         actionSheet.tag = STATUS_ACTIONSHEET_CUSTOMER_FINISHED;
         actionSheet.data = @(indexPath.row);
         [actionSheet showInView:[aCollectionView cellForItemAtIndexPath:indexPath]];
         
         } else if ([task.status intValue] == TaskStatusCreated){
         // task has been delivered, not reviewed yet.
         CustomActionSheet *actionSheet =
         [[CustomActionSheet alloc] initWithTitle:nil
         delegate:self
         cancelButtonTitle:@"Cancel"
         destructiveButtonTitle:@"Messages"
         otherButtonTitles:@"Edit", nil];
         actionSheet.tag = STATUS_ACTIONSHEET_CUSTOMER_OPEN;
         actionSheet.data = @(indexPath.row);
         [actionSheet showInView:[aCollectionView cellForItemAtIndexPath:indexPath]];
         } else {
         // otherwise just go to messages
         [self performSegueWithIdentifier:@"Messages" sender:task];
         }
         }
         
         } else {
         // employee
         
         if ([task.status intValue] == TaskStatusAssigned) {
         
         CustomActionSheet *actionSheet = [[CustomActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Messages" otherButtonTitles:@"Finish", @"Resign", nil];
         actionSheet.data = @(indexPath.row);
         actionSheet.tag = STATUS_ACTIONSHEET_EMPOLYEE_ASSIGNED;
         [actionSheet showInView:[aCollectionView cellForItemAtIndexPath:indexPath]];
         
         } else if ([task.status intValue] == TaskStatusFinished){
         
         CustomActionSheet *actionSheet = [[CustomActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Messages" otherButtonTitles:@"Rate", nil];
         actionSheet.data = @(indexPath.row);
         actionSheet.tag = STATUS_ACTIONSHEET_EMPOLYEE_DELIVERED;
         [actionSheet showInView:[aCollectionView cellForItemAtIndexPath:indexPath]];
         
         } else {
         [self performSegueWithIdentifier:@"Messages" sender:task];
         }
         }
         
         */
    }
}

#pragma mark Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Messages"])
    {
        [(TaskMessageViewController *)segue.destinationViewController setTask:sender];
    }
    else if ([segue.destinationViewController isKindOfClass:[TaskDetailViewController class]])
    {
        [(TaskDetailViewController *)segue.destinationViewController setTask:sender];
    }
}

#pragma mark UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (![actionSheet isKindOfClass:[CustomActionSheet class]])
        return;
    
    if (actionSheet.cancelButtonIndex == buttonIndex)
        return;
    
    int taskIndex = [[(CustomActionSheet *)actionSheet data] intValue];
    if (taskIndex >= [self.tasks count])
        return;
    
    Task *task = self.tasks[taskIndex];
    
    if (actionSheet.tag == STATUS_ACTIONSHEET_EMPOLYEE_ASSIGNED) {
        
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            // Messages
            [self performSegueWithIdentifier:@"Messages" sender:task];
        }
        else if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            // Finish Task
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            
            __weak typeof (self) wself = self;
            [task deliverTaskWithCompletionHandler:^(BOOL success, NSString *errorDesc) {
                
                [SVProgressHUD dismiss];
                
                PlanDetailViewController *sself = wself;
                
                if (!sself)
                    return;
                
                [sself reloadLocalData:nil];
                
                if (!success) {
                    [[[UIAlertView alloc] initWithTitle:@"Warning" message:errorDesc delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
            }];
        } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
            
            // Resign Task
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            
            __weak typeof (self) wself = self;
            [task resignTaskWithCompletionHandler:^(BOOL success, NSString *errorDesc) {
                
                [SVProgressHUD dismiss];
                
                PlanDetailViewController *sself = wself;
                
                if (!sself)
                    return;
                
                if (!success) {
                    [[[UIAlertView alloc] initWithTitle:@"Warning" message:errorDesc delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                } else {
                    [sself reloadLocalData:nil];
                }
            }];
        }
        
    }
    else if (actionSheet.tag == STATUS_ACTIONSHEET_EMPOLYEE_DELIVERED) {
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            // Messages
            [self performSegueWithIdentifier:@"Messages" sender:task];
        }
        else if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            // Review Task (Rate the customer & Employee)
            [[AppDelegate sharedInstance].rootViewController openTaskReviewModalForTask:task];
        }
    }
    else if (actionSheet.tag == STATUS_ACTIONSHEET_CUSTOMER_FINISHED) {
        
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            // Messages
            [self performSegueWithIdentifier:@"Messages" sender:task];
        }
        else if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            // Rate the employee on the task
            [[AppDelegate sharedInstance].rootViewController openTaskReviewModalForTask:task];
        }
    }
    else if (actionSheet.tag == STATUS_ACTIONSHEET_CUSTOMER_OPEN) {
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            // Messages
            [self performSegueWithIdentifier:@"Messages" sender:task];
        }
        else if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            // Edit
            [self performSegueWithIdentifier:@"editTask" sender:task];
        }
    }
}

- (void)dashboardTaskPopup:(DashboardTaskPopup *)popup didDismissWithTypes:(NSArray *)types
{
    
//    NewTaskViewController *vc = [NewTaskViewController newTaskViewControllerWithTypes:types];
//    vc.taskDelegate = self;
//    if (vc != nil)
//    {
//        CATransition *transition = [CATransition animation];
//        transition.duration = 0.3;
//        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//        transition.type = kCATransitionPush;
//        transition.subtype = kCATransitionFromRight;
//        [self.view.window.layer addAnimation:transition forKey:nil];
//        [self.navigationController presentViewController:vc animated:NO completion:nil];
//    }
}

//- (void)newTaskViewController:(NewTaskViewController *)vc didFailWithError:(NSError *)error
//{
//    CATransition *transition = [CATransition animation];
//    transition.duration = 0.3;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    transition.type = kCATransitionPush;
//    transition.subtype = kCATransitionFromLeft;
//    [self.view.window.layer addAnimation:transition forKey:nil];
//    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
//    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alertView show];
//}
//
//- (void)newTaskViewController:(NewTaskViewController *)vc didFinishWithResult:(BOOL)result
//{
//    CATransition *transition = [CATransition animation];
//    transition.duration = 0.3;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    transition.type = kCATransitionPush;
//    transition.subtype = kCATransitionFromLeft;
//    [self.view.window.layer addAnimation:transition forKey:nil];
//    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
//}
//
//- (void)newTaskViewControllerDidCancel:(NewTaskViewController *)vc
//{
//    CATransition *transition = [CATransition animation];
//    transition.duration = 0.3;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    transition.type = kCATransitionPush;
//    transition.subtype = kCATransitionFromLeft;
//    [self.view.window.layer addAnimation:transition forKey:nil];
//    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
//}

@end
