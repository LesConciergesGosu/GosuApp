//
//  NotificationsViewController.m
//  Gosu
//
//  Created by dragon on 6/14/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "NotificationsViewController.h"
#import "UIViewController+ViewDeck.h"
#import "NotificationCell.h"
#import "Notification+Extra.h"
#import "User+Extra.h"
#import "Task+Extra.h"
#import "PushManager.h"

@interface NotificationsViewController ()<UITableViewDataSource, UITableViewDelegate, RemovableCellDelegate>

@property (nonatomic, strong) NSMutableArray *notifications;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation NotificationsViewController

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
    
    self.title = @"Notifications";
    
    self.notifications = [[[User currentUser] notifications] mutableCopy];
    [self reloadData];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor grayColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshControlValueChanged:)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadLocalData:)
                                                 name:NotificationNotificationListUpdated
                                               object:nil];
}

- (void) refreshControlValueChanged:(id)sender
{
    [self.refreshControl beginRefreshing];
    
    __weak NotificationsViewController *wself = self;
    [[User currentUser] pullNotificationsWithCompletionHandler:^(BOOL success, NSString *errorDesc) {
        
        __strong NotificationsViewController *sself = wself;
        if (sself) {
            
            if (errorDesc)
                DLog(@"Error : %@", errorDesc);
            
            [sself reloadLocalData:nil];
            
            [sself.refreshControl endRefreshing];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNotificationListUpdated object:nil];
    }];
}

#pragma mark Privates

- (void) reloadLocalData:(id)sender
{
    self.notifications = [[User currentUser].notifications mutableCopy];
    [self.tableView reloadData];
    
    [self autoMarkReadAllNotifications];
}

- (void) reloadData
{
    if ([self.refreshControl isRefreshing])
        return;
    
    [self refreshControlValueChanged:nil];
}

- (void) autoMarkReadAllNotifications
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %@", @(NotificationStatusUnread)];
    NSArray *array = [self.notifications filteredArrayUsingPredicate:predicate];
    
    NSMutableArray *array2 = [NSMutableArray array];
    NSMutableArray *taskArrayToUpdate = [NSMutableArray array];
    for (Notification *notification in array) {
        if ([notification needToAutoMarkRead]) {
            [array2 addObject:notification.objectId];
            
            if (notification.task != nil) {
                switch ([notification.type intValue]) {
                    case PushTypeTaskAccepted:
                    case PushTypeTaskResigned:
                        [taskArrayToUpdate addObject:notification.task.objectId];
                        break;
                        
                    default:
                        break;
                }
            }
        }
    }
    
    if ([array2 count] == 0)
        return;
    
    __weak NotificationsViewController *wself = self;
    [[User currentUser] readNotifications:array2 completionHandler:^(BOOL success, NSString *errorDesc) {
        
        __strong NotificationsViewController *sself = wself;
        if (sself) {
            
            if (errorDesc)
                DLog(@"Error : %@", errorDesc);
            
            sself.notifications = [[[User currentUser] notifications] mutableCopy];
            [sself.tableView reloadData];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNotificationListUpdated object:nil];
    }];
    
    [Task refreshTasks:taskArrayToUpdate CompletionHandler:^(BOOL success, NSString *errorDesc) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshTaskListView object:nil];
    }];
}


#pragma mark UITableView DataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.notifications count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationRead"];
    
    cell.delegate = self;
    cell.swipeToDeleteEnabled = YES;
    [cell setData:self.notifications[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [NotificationCell heightForData:self.notifications[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[PushManager manager] handleNotification:self.notifications[indexPath.row]];
}

- (BOOL)shouldRemoveableCellRemoved:(RemovableCell *)cell
{
    
    Notification *notification = [cell data];
    
    if (notification) {
        
        NSInteger index = [self.notifications indexOfObject:notification];
        
        if (index != NSNotFound) {
            
            [[User currentUser] deleteNotification:notification.objectId completionHandler:nil];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.notifications removeObject:notification];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        }
        
        return YES;
    }
    
    return NO;
}

@end
