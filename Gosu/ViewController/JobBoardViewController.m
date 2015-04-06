//
//  JobBoardViewController.m
//  Gosu
//
//  Created by dragon on 4/20/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "JobBoardViewController.h"
#import "UIViewController+ViewDeck.h"
#import "TaskCollectionViewCell.h"
#import "CustomActionSheet.h"
#import "CustomAlertView.h"
#import "PFUser+Extra.h"
#import "User+Extra.h"
#import "Task+Extra.h"
#import <SVProgressHUD/SVProgressHUD.h>

#define JOBBOARD_ACTIONSHEET_ACTION 100
#define JOBBOARD_ALERT_ACCEPT_TASK 100
#define JOBBOARD_ALERT_IGNORE_TASK 101

@interface JobBoardViewController ()<UICollectionViewDataSource,
UICollectionViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSArray *jobs;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation JobBoardViewController

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
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Job Board";
    
    // add refresh control to the collection view
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor grayColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshControlValueChanged:)
                  forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    [self.collectionView setAlwaysBounceVertical:YES];
    
    
    // preload the tasks
    
    if ([PFUser currentUser])
    {
        [self reloadLocalData:nil];
        [self reloadData:nil];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self performSelector:@selector(reloadData:) withObject:nil afterDelay:2.f];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}


#pragma mark Privates
- (void) reloadData:(id)sender {
    
    if ([self.refreshControl isRefreshing])
        return;
    
    
    [self.collectionView reloadData];
    [self refreshControlValueChanged:nil];
}

- (void) reloadLocalData:(id)sender {
    
    User *me = [User currentUser];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %@", @(TaskStatusCreated)];
    self.jobs = [[me.jobs array] filteredArrayUsingPredicate:predicate];
    [self.collectionView reloadData];
}

#pragma mark Actions
- (void) refreshControlValueChanged:(id)sender
{
    [self.refreshControl beginRefreshing];
    
    __weak JobBoardViewController *wself = self;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [Task loadJobsWithCompletionHandler:^(BOOL success, NSString *errorDesc) {
        
        JobBoardViewController *sself = wself;
        
        if (sself) {
            if (success)
                [sself reloadLocalData:nil];
            [sself.refreshControl endRefreshing];
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [sself performSelector:@selector(reloadData:) withObject:nil afterDelay:2.f];
        }
        
        if (errorDesc) {
            DLog(@"failed to pull task with an error : %@", errorDesc);
        }
        
    }];
}

#pragma mark Collection View
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self jobs].count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)aCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    TaskCollectionViewCell *cell = (TaskCollectionViewCell *)
    [aCollectionView dequeueReusableCellWithReuseIdentifier:@"taskCell" forIndexPath:indexPath];
    
    if (indexPath.item < [self jobs].count) {
        [cell setTask:self.jobs[indexPath.item]];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)aCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [aCollectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (indexPath.item < [self jobs].count)
    {
        CustomActionSheet *actionSheet =
        [[CustomActionSheet alloc] initWithTitle:nil
                                        delegate:self
                               cancelButtonTitle:@"Cancel"
                          destructiveButtonTitle:@"Accept"
                               otherButtonTitles:@"Ignore", nil];
        actionSheet.tag = JOBBOARD_ACTIONSHEET_ACTION;
        actionSheet.data = @(indexPath.row);
        [actionSheet showInView:[aCollectionView cellForItemAtIndexPath:indexPath]];
        
        
    }
}

#pragma mark UIAlert View Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == JOBBOARD_ACTIONSHEET_ACTION) {
        
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            // Accept
            CustomAlertView *alert =
            [[CustomAlertView alloc] initWithTitle:@"Accept"
                                           message:@"Would you like to accept this task?"
                                          delegate:self
                                 cancelButtonTitle:@"Nope"
                                 otherButtonTitles:@"Accept", nil];
            alert.data = [(CustomActionSheet *)actionSheet data];
            alert.tag = JOBBOARD_ALERT_ACCEPT_TASK;
            [alert show];
        }
        else if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            // Ignore
            CustomAlertView *alert =
            [[CustomAlertView alloc] initWithTitle:@"Ignore"
                                           message:@"You can't see this job posting anymore after ignore. Will you continue?"
                                          delegate:self
                                 cancelButtonTitle:@"Nope"
                                 otherButtonTitles:@"Continue", nil];
            alert.data = [(CustomActionSheet *)actionSheet data];
            alert.tag = JOBBOARD_ALERT_IGNORE_TASK;
            [alert show];
        }
    }
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (![alertView isKindOfClass:[CustomAlertView class]])
        return;
    
    if (alertView.tag == JOBBOARD_ALERT_ACCEPT_TASK) {
        
        if (buttonIndex == alertView.firstOtherButtonIndex)
        {
            int index = [[(CustomAlertView *)alertView data] intValue];
            
            if (index < [self.jobs count]) {
                
                __weak typeof (self) wself = self;
                
                [SVProgressHUD showWithStatus:@""];
                [self.jobs[index] acceptTaskWithCompletionHandler:^(BOOL success, NSString *errorDesc) {
                    
                    JobBoardViewController *sself = wself;
                    [SVProgressHUD dismiss];
                    if (!success) {
                        [[[UIAlertView alloc] initWithTitle:@"Warning" message:errorDesc delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    } else {
                        [sself reloadLocalData:nil];
                    }
                }];
            }
        }
    }
    else if (alertView.tag == JOBBOARD_ALERT_IGNORE_TASK) {
        
        if (buttonIndex == alertView.firstOtherButtonIndex)
        {
            int index = [[(CustomAlertView *)alertView data] intValue];
            
            if (index < [self.jobs count]) {
                
                __weak typeof (self) wself = self;
                
                [SVProgressHUD showWithStatus:@""];
                [self.jobs[index] ignoreJobPostingWithCompletionHandler:^(BOOL success, NSString *errorDesc) {
                    
                    JobBoardViewController *sself = wself;
                    
                    [SVProgressHUD dismiss];
                    if (!success) {
                        [[[UIAlertView alloc] initWithTitle:@"Warning" message:errorDesc delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    } else {
                        [sself reloadLocalData:nil];
                    }
                }];
            }
        }
    }
    
}

@end
