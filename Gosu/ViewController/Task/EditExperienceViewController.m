//
//  EditExperienceViewController.m
//  Gosu
//
//  Created by Dragon on 11/26/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "EditExperienceViewController.h"
#import "Experience+Extra.h"
#import "Task+Extra.h"
#import "PTask.h"
#import "ExperienceTaskTableCell.h"
#import "ButtonCell.h"
#import "NewTaskBaseViewController.h"
#import "AppAppearance.h"
#import "DashboardTaskPopup.h"
#import "NSString+Task.h"
#import "PushModalTransitionAnimator.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface EditExperienceViewController ()<UITableViewDataSource, UITableViewDelegate, ExperienceTaskTableCellDelegate, ButtonCellDelegate, DashboardTaskPopupDelegate, NewTaskItemDelegate, UIViewControllerTransitioningDelegate>
{
    BOOL _changed;
}

@property (nonatomic, strong) NSMutableArray *tasks;
@property (nonatomic, strong) NSMutableArray *removedTasks;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@end

@implementation EditExperienceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"MOVIE WITH SUSIE";
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone:)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    _changed = NO;
    
    [self reloadLocalData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadLocalData
{
    self.removedTasks = [NSMutableArray array];
    
    NSMutableArray *array = [NSMutableArray array];
    for (Task *task in self.experience.tasks) {
        [array addObject:[task PFObject]];
    }
    
    //self.tasks = [self.experience.tasks mutableCopy];
    self.tasks = array;
}

#pragma mark Editing
- (void) onDone:(id)sender
{
    if (_changed) {
        
        [SVProgressHUD show];
        
        __weak EditExperienceViewController *wself = self;
        [Experience editExperienceWithId:self.experience.objectId WithPFTasks:self.tasks completion:^(BOOL success, id pfObject, NSString *errorDesc) {
            
            [SVProgressHUD dismiss];
            
            __strong EditExperienceViewController *sself = wself;
            
            if (!sself)
                return;
            
            if (success)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationExperienceUpdated object:sself.experience];
                [sself.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:@"Failed"];
                DLog(@"Error : %@", errorDesc);
            }
        }];
    }
}

#pragma mark UICollectionView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tasks count] * 2 + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row % 2 == 0) ? 36 : 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *res = nil;
    
    if (indexPath.row % 2 == 1)
    {
        PTask *task = self.tasks[(NSInteger)floorf(indexPath.row / 2)];
        UIColor *typeColor = [Task colorForType:task.type];
        
        ExperienceTaskTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskCell"];
        
        for (UIView *colorView in cell.colorViews)
            colorView.backgroundColor = typeColor;
        
        cell.lblTitle.text = [Task shortTitleForType:task.type subType:task.type2];
        cell.imvType.image = [Task iconForType:task.type subType:task.type2];
        cell.delegate = self;
        
        res = cell;
    }
    else
    {
        ButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlusCell"];
        cell.delegate = self;
        res = cell;
    }
    
    return res;
}

- (void)experienceTaskTableCell:(id)cell tappedButtonAtIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSInteger taskIndex = (NSInteger)floorf(indexPath.row / 2);
    PTask *task = self.tasks[taskIndex];
    
    if (index == 0) // Edit
    {
        self.selectedIndexPath = indexPath;
        
        NewTaskBaseViewController *rootVC = [NewTaskBaseViewController viewControllerWithPTask:task];
        rootVC.delegate = self;
        rootVC.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"CANCEL" style:UIBarButtonItemStyleBordered target:self action:@selector(onAddTaskCancel:)];
        rootVC.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"DONE" style:UIBarButtonItemStyleBordered target:rootVC action:@selector(onDone:)];
        
        if (rootVC) {
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootVC];
            [navController setNavigationBarHidden:NO];
            [navController.navigationBar setTranslucent:YES];
            [navController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
            [navController.navigationBar setBackgroundColor:[UIColor clearColor]];
            
            if (navController != nil)
            {
                navController.modalPresentationStyle = UIModalPresentationCustom;
                navController.transitioningDelegate = self;
                [self presentViewController:navController animated:YES completion:nil];
            }
        }
    }
    else // delete
    {
        [self.removedTasks addObject:task];
        [self.tasks removeObjectAtIndex:taskIndex];
        [self.tableView reloadData];
        
        _changed = YES;
    }
}

- (void)buttonCell:(ButtonCell *)cell tappedButtonAtIndex:(NSInteger)buttonIndex
{
    
    self.selectedIndexPath = [self.tableView indexPathForCell:cell];
    
    DashboardTaskPopup *taskPopup = [DashboardTaskPopup taskPopupWithNavigationController:self.navigationController];
    taskPopup.singleTask = YES;
    taskPopup.delegate = self;
    
    [taskPopup presentAnimated:YES screenshot:self.navigationController.view completion:nil];
}

- (void)dashboardTaskPopup:(DashboardTaskPopup *)popup didDismissWithTypes:(NSArray *)types
{
    
    NSString *type = [types firstObject];
    
    
    NewTaskBaseViewController *rootVC = [NewTaskBaseViewController viewControllerWithType:[type mainType] subType:[type subType]];
    rootVC.delegate = self;
    rootVC.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"CANCEL" style:UIBarButtonItemStyleBordered target:self action:@selector(onAddTaskCancel:)];
    rootVC.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"DONE" style:UIBarButtonItemStyleBordered target:rootVC action:@selector(onDone:)];
    
    if (rootVC) {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootVC];
        [navController setNavigationBarHidden:NO];
        [navController.navigationBar setTranslucent:YES];
        [navController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [navController.navigationBar setBackgroundColor:[UIColor clearColor]];
        
        if (navController != nil)
        {
            navController.modalPresentationStyle = UIModalPresentationCustom;
            navController.transitioningDelegate = self;
            [self presentViewController:navController animated:YES completion:nil];
        }
    }
}

#pragma mark Add New Task

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


- (void) onAddTaskCancel:(id)sender
{
    self.selectedIndexPath = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)newTaskItemController:(NewTaskBaseViewController *)vc didFinishWithResult:(id)result
{
    
    if (result) {
        
        if (self.selectedIndexPath.row % 2 == 0) { // Add
            [(PTask *)result setChanged:YES];
            [self.tasks insertObject:result atIndex:self.selectedIndexPath.row / 2];
            [self.tableView reloadData];
        } else { // Edit
            
            PTask *task = self.tasks[self.selectedIndexPath.row / 2];
            
            for (NSString *key in [(PFObject *)result allKeys]) {
                [task setObject:[(PFObject *)result objectForKey:key] forKey:key];
            }
            
            task.changed = YES;
            
            [self.tableView reloadData];
        }
        
        _changed = YES;
        
        self.selectedIndexPath = nil;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
