//
//  LoginBaseViewController.m
//  Gosu
//
//  Created by dragon on 3/21/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "LoginBaseViewController.h"
#import "PushManager.h"
#import "PFUser+Extra.h"
#import "User+Extra.h"
#import "Task+Extra.h"

@interface LoginBaseViewController ()

@end

@implementation LoginBaseViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) completeLoginProcess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationLoggedIn object:nil];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    [[PushManager manager] resetBadgeNumber:nil];
    
    if ([PFUser currentUser] && [[PFUser currentUser] isAuthenticated]) {
        
        if ([User currentUser] != nil) {
            
            [[User currentUser] pullNotificationsWithCompletionHandler:nil];
            
            NSDate *date = [NSDate date];
            NSDate *since = [[NSUserDefaults standardUserDefaults] objectForKey:kLastFetchUnreadMessages];
            [Task refreshUnreadMessagesForAllTasksSince:since CompletionHandler:^(BOOL success, NSString *errorDesc) {
                if (success) {
                    [[NSUserDefaults standardUserDefaults] setObject:date forKey:kLastFetchUnreadMessages];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationUpdatedUnreadMessageCounts object:nil];
                }
            }];
        }
    }
}

@end
