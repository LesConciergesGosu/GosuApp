//
//  StatusViewController.m
//  Gosu
//
//  Created by dragon on 3/19/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "StatusViewController.h"
#import "UIViewController+ViewDeck.h"
#import "TaskCollectionViewCell.h"
#import "TaskMessageViewController.h"
#import "CreateTaskViewController.h"
#import "CustomAlertView.h"
#import "CustomActionSheet.h"
#import "AppDelegate.h"
#import "PFUser+Extra.h"
#import "User+Extra.h"
#import "Task+Extra.h"
#import "Tutorial.h"

#import <SVProgressHUD/SVProgressHUD.h>

#define STATUS_ACTIONSHEET_EMPOLYEE_ASSIGNED 10
#define STATUS_ACTIONSHEET_EMPOLYEE_DELIVERED 11
#define STATUS_ACTIONSHEET_CUSTOMER_FINISHED 21
#define STATUS_ACTIONSHEET_CUSTOMER_OPEN 20

@interface StatusViewController ()<UICollectionViewDataSource,
UICollectionViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSArray *tasks;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation StatusViewController

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
    
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)] ) {
        [self.navigationController interactivePopGestureRecognizer].enabled = NO;
    }
    
    self.title = @"Status";
    
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    
    
    // add refresh control to the collection view
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor grayColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshControlValueChanged:)
                  forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    [self.collectionView setAlwaysBounceVertical:YES];
    
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
    
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    if ([PFUser currentUser])
    {
        if ([PFUser currentUser].userType == UserTypeCustomer) {
            if (self.bottomBar.hidden) {
                self.bottomBar.hidden = NO;
                
                CGRect frame = self.collectionView.frame;
                frame.size.height = self.view.frame.size.height - frame.origin.y - 30;
                self.collectionView.frame = frame;
            }
        } else if (!self.bottomBar.hidden) {
            self.bottomBar.hidden = YES;
            CGRect frame = self.collectionView.frame;
            frame.size.height = self.view.frame.size.height - frame.origin.y;
            self.collectionView.frame = frame;
        }
        
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
    
    User *user = [User currentUser];
    
    if (![[user tutorialInstance].createTask boolValue]) {
        [user tutorialInstance].createTask = @(YES);
        [self onAddTask:nil];
        
        if ([user.managedObjectContext hasChanges]) {
            [user.managedObjectContext saveRecursively];
        }
    }
    
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
    
    [self onSwitchStatus:nil];
    [self.collectionView reloadData];
}

#pragma mark Actions

- (void) refreshControlValueChanged:(id)sender
{
    [self.refreshControl beginRefreshing];
    
    __weak StatusViewController *wself = self;
    
    NSArray *statusArray = nil;
    
    switch ([self.segmentedControl selectedSegmentIndex]) {
        case 0: // Open
            statusArray = @[@(TaskStatusCreated), @(TaskStatusAssigned)];
            break;
            
        case 1: // Closed
            statusArray = @[@(TaskStatusFinished), @(TaskStatusReviewed)];
            break;
            
        default:
            break;
    }
    
    [Task loadMyTasksWithStatus:statusArray CompletionHandler:^(BOOL success, NSString *errorDesc) {
        StatusViewController *sself = wself;
        if (success && sself) {
            [sself.refreshControl endRefreshing];
            [sself reloadLocalData:nil];
        } else if (errorDesc) {
            DLog(@"failed to pull task with an error : %@", errorDesc);
        }
    }];
}

- (IBAction)onSwitchStatus:(UISegmentedControl *)sender
{
    
    NSArray *array;
    
    switch ([self.segmentedControl selectedSegmentIndex]) {
        case 0: // Open
            array = [[User currentUser] fetchOpenTasksWithLimit:0];
            break;
            
        case 1: // Closed
            array = [[User currentUser] fetchFinishedTasksWithLimit:0];
            break;
            
        default:
            break;
    }
    
    self.tasks = array;
    [self.collectionView reloadData];
}

- (IBAction)onAddTask:(id)sender
{
    if ([PFUser currentUser].userType == UserTypeCustomer)
        [self performSegueWithIdentifier:@"createTask" sender:nil];
}


#pragma mark Collection View
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self tasks].count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)aCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    TaskCollectionViewCell *cell = (TaskCollectionViewCell *)
        [aCollectionView dequeueReusableCellWithReuseIdentifier:@"taskCell" forIndexPath:indexPath];
    
    if (indexPath.item < [self tasks].count) {
        
//        Task *task = self.tasks[indexPath.item];
        
//        if ([task isFault]) {
//            DLog(@"Unexpected excpetion : task is fault : %@", task);
//            [cell setTask:nil];
//        } else {
            [cell setTask:self.tasks[indexPath.item]];
//        }
    }
    
    return cell;
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
    }
}

#pragma mark Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Messages"])
    {
        [(TaskMessageViewController *)segue.destinationViewController setTask:sender];
    }
    else if ([segue.identifier isEqualToString:@"editTask"])
    {
        [(CreateTaskViewController *)segue.destinationViewController setTask:sender];
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
            [SVProgressHUD showWithStatus:@""];
            
            __weak typeof (self) wself = self;
            [task deliverTaskWithCompletionHandler:^(BOOL success, NSString *errorDesc) {
                
                [SVProgressHUD dismiss];
                
                StatusViewController *sself = wself;
                
                if (!sself)
                    return;
                
                [sself reloadLocalData:nil];
                
                if (!success) {
                    [[[UIAlertView alloc] initWithTitle:@"Warning" message:errorDesc delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
            }];
        } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
            
            // Resign Task
            [SVProgressHUD showWithStatus:@""];
            
            __weak typeof (self) wself = self;
            [task resignTaskWithCompletionHandler:^(BOOL success, NSString *errorDesc) {
                
                [SVProgressHUD dismiss];
                
                StatusViewController *sself = wself;
                
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

@end
