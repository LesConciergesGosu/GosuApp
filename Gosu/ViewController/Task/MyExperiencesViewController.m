//
//  MyExperiencesViewController.m
//  Gosu
//
//  Created by dragon on 3/19/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "MyExperiencesViewController.h"
#import "UIViewController+ViewDeck.h"
#import "TaskCollectionViewCell.h"
#import "TaskCustomerCell.h"
#import "TaskMessageViewController.h"
#import "TaskDetailViewController.h"
#import "ConfirmExperienceViewController.h"
#import "CustomAlertView.h"
#import "CustomActionSheet.h"
#import "DashboardTaskPopup.h"
#import "AppDelegate.h"

#import <SVProgressHUD/SVProgressHUD.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

#import "PFUser+Extra.h"
#import "Experience+Extra.h"
#import "User+Extra.h"
#import "Task+Extra.h"
#import "NSString+Task.h"
#import "DataManager.h"
#import "ExperienceTaskCell.h"
#import "ExperienceHeaderView.h"
#import "ExperienceFooterView.h"

#define STATUS_ACTIONSHEET_EMPOLYEE_ASSIGNED 10
#define STATUS_ACTIONSHEET_EMPOLYEE_DELIVERED 11
#define STATUS_ACTIONSHEET_CUSTOMER_FINISHED 21
#define STATUS_ACTIONSHEET_CUSTOMER_OPEN 20

typedef NS_ENUM(NSInteger, MyExperiencesTabIndex){
    MyExperiencesTabIndexItinerary,
    MyExperiencesTabIndexPending
};

@interface MyExperiencesViewController ()<UICollectionViewDataSource,
UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ExperienceTaskCellDelegate>
{
    MyExperiencesTabIndex currentTabIndex;
    CGFloat screenWidth;
}

@property (nonatomic, strong) DashboardTaskPopup *taskPopup;
@property (nonatomic, strong) NSArray *experiences;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSDateFormatter *expDateFormatter;
@end

@implementation MyExperiencesViewController

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
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"E MM/dd"];
    self.expDateFormatter = dateFormatter;
    
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)] ) {
        [self.navigationController interactivePopGestureRecognizer].enabled = NO;
    }
    
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    
    currentTabIndex = MyExperiencesTabIndexItinerary;
    self.btnTabItinerary.selected = YES;
    self.btnTabPending.selected = NO;
    
    UINib *headerNib = [UINib nibWithNibName:@"ExperienceHeaderView" bundle:nil];
    [self.collectionView registerNib:headerNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ExperienceHeaderView"];
    
    UINib *footerNib = [UINib nibWithNibName:@"ExperienceFooterView" bundle:nil];
    [self.collectionView registerNib:footerNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ExperienceFooterView"];
    
    
    // add refresh control to the collection view
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor whiteColor];
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
                                             selector:@selector(reloadLocalData:)
                                                 name:NotificationExperienceUpdated
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
    
    if (currentTabIndex == MyExperiencesTabIndexItinerary)
        self.experiences = [[User currentUser] fetchItineraryExperiencesWithLimit:0 resultType:NSManagedObjectResultType];
    else
        self.experiences = [[User currentUser] fetchPendingExperiencesWithLimit:0 resultType:NSManagedObjectResultType];
    
    [self.collectionView reloadData];
}

#pragma mark Actions

- (void) refreshControlValueChanged:(id)sender
{
    [self.refreshControl beginRefreshing];
    
    __weak MyExperiencesViewController *wself = self;
    
    NSArray *statusArray = nil;
    
    if (currentTabIndex == MyExperiencesTabIndexItinerary)
    {
        statusArray = @[@(ExperienceStatusConfirmed), @(ExperienceStatusFinished), @(ExperienceStatusReviewed)];
    }
    else
    {
        statusArray = @[@(ExperienceStatusCreated)];
    }
    
    [Experience loadMyExperiencesWithStatus:statusArray CompletionHandler:^(BOOL success, NSString *errorDesc) {
        MyExperiencesViewController *sself = wself;
        if (success && sself) {
            [sself.refreshControl endRefreshing];
            [sself reloadLocalData:nil];
        } else if (errorDesc) {
            DLog(@"failed to pull the experiences with an error : %@", errorDesc);
        }
    }];
}

- (IBAction)onSwitchStatus:(UIButton *)sender
{
    
    if (sender == self.btnTabItinerary &&
        currentTabIndex != MyExperiencesTabIndexItinerary)
    {
        currentTabIndex = MyExperiencesTabIndexItinerary;
        self.btnTabItinerary.selected = YES;
        self.btnTabPending.selected = NO;
    }
    else if (sender == self.btnTabPending &&
             currentTabIndex != MyExperiencesTabIndexPending)
    {
        currentTabIndex = MyExperiencesTabIndexPending;
        self.btnTabItinerary.selected = NO;
        self.btnTabPending.selected = YES;
    }
    else
    {
        //do nothing
    }
    
    [self reloadLocalData:nil];
}

#pragma mark Collection View

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width - 24, 94);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, 64);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, 15);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.experiences count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    Experience *experience = self.experiences[section];
    
    return [experience.tasks count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        ExperienceHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ExperienceHeaderView" forIndexPath:indexPath];
        header.index = indexPath.section;
        
        Experience *experience = self.experiences[indexPath.section];
        
        header.lblTitle.text = @"Movie with Susie";
        header.lblDesc.text = [[self.expDateFormatter stringFromDate:experience.createdAt] uppercaseString];
        
        __weak MyExperiencesViewController *wself = self;
        [header setTapButtonBlock:^(ExperienceHeaderView *object) {
            
            __strong MyExperiencesViewController *sself = wself;
            
            if (!sself)
                return;
            
            Experience *experience = sself.experiences[object.index];
            [sself performSegueWithIdentifier:@"ConfirmExperience" sender:experience];
            
        }];
        
        return header;
    }
    else if ([kind isEqualToString:UICollectionElementKindSectionFooter])
    {
        ExperienceFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ExperienceFooterView" forIndexPath:indexPath];
        
        return footer;
    }
    
    return nil;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)aCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell *res = nil;
    
    Experience *experience = self.experiences[indexPath.section];
    Task *task = [experience.tasks objectAtIndex:indexPath.row];
    
    if ([task.status integerValue] < TaskStatusAssigned) {
        
        ExperienceTaskCell *cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:@"ExperienceTaskNotAssignedCell" forIndexPath:indexPath];
        
        UIColor *typeColor = [Task colorForType:task.type];
        
        cell.viewTitle.backgroundColor = typeColor;
        cell.viewType.backgroundColor = typeColor;
        cell.lblTitle.text = [Task shortTitleForType:task.type subType:task.type2];
        cell.imvType.image = [Task iconForType:task.type subType:task.type2];
        cell.delegate = self;
        
        res = cell;
        
    } else {
        
        ExperienceTaskCell *cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:@"ExperienceTaskCell" forIndexPath:indexPath];
        
        UIColor *typeColor = [Task colorForType:task.type];
        
        cell.viewTitle.backgroundColor = typeColor;
        cell.viewType.backgroundColor = typeColor;
        cell.lblTitle.text = [Task shortTitleForType:task.type subType:task.type2];
        cell.imvType.image = [Task iconForType:task.type subType:task.type2];
        cell.delegate = self;
        
        User *employee = nil;
        if ((employee = [task mainWorker])) {
            cell.lblEmployeeName.text = [employee fullName];
            NSString *photoUrlString = [employee photo];
            
            [cell.imvEmployeePhoto setImageWithURL:[NSURL URLWithString:photoUrlString] placeholderImage:[UIImage imageNamed:@"buddy"]];
        } else {
            cell.lblEmployeeName.text = @"";
            [cell.imvEmployeePhoto cancelImageRequestOperation];
            cell.imvEmployeePhoto.image = [UIImage imageNamed:@"buddy"];
        }
        
        res = cell;
    }
    
    
    
    return res;
}

- (void)collectionView:(UICollectionView *)aCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [aCollectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    Experience *experience = self.experiences[indexPath.section];
    
    if ([experience.status integerValue] == ExperienceStatusCreated)
    {
        [self performSegueWithIdentifier:@"ConfirmExperience" sender:experience];
    }
    else
    {
        
    }
    
}

- (void)experienceTaskCell:(ExperienceTaskCell *)cell tappedButtonAtIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    Experience *experience = self.experiences[indexPath.section];
    Task *task = [experience.tasks objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"Messages" sender:task];
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
    else if ([segue.destinationViewController isKindOfClass:[ConfirmExperienceViewController class]])
    {
        [(ConfirmExperienceViewController *)segue.destinationViewController setExperience:sender];
    }
}


@end
