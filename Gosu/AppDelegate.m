//
//  AppDelegate.m
//  Gosu
//
//  Created by dragon on 3/19/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "AppDelegate.h"
#import "SplashViewController.h"
#import "TaskMessageViewController.h"
#import "StatusViewController.h"
#import "CustomAlertView.h"
#import "PTask.h"
#import "User+Extra.h"
#import "Task+Extra.h"
#import "PushManager.h"
#import "LocationManager.h"
#import "DataManager.h"
#import <Mixpanel/Mixpanel.h>


@interface AppDelegate()
{
    UIBackgroundTaskIdentifier backgroundTask;
}
@end

@implementation AppDelegate

+ (AppDelegate *)sharedInstance
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    DLog(@"lauch options : %@", launchOptions);
    
    if ([launchOptions[UIApplicationLaunchOptionsLocationKey] boolValue])
    {
        [self beginBackgroundTask];
    }
    
    // Override point for customization after application launch.
    [self setupAppearance];
    [LocationManager manager];
    [PushManager manager];
    [[DataManager manager] setupParse];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainViewController *mainVC = (MainViewController *)[storyboard instantiateViewControllerWithIdentifier:@"mainViewController"];
    self.window.rootViewController = mainVC;
    [self.window makeKeyAndVisible];
    
    self.rootViewController = mainVC;
    
    SplashViewController *splashVC = [storyboard instantiateViewControllerWithIdentifier:@"splashViewController"];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:splashVC];
    navVC.navigationBarHidden = YES;
    [mainVC presentViewController:navVC animated:NO completion:nil];

    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    
    NSDictionary *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notification != nil)
        [[PushManager manager] handlePushMessage:notification CompletionHandler:nil];
    
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced)
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = !notification;
        
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload)
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    }
    
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    
    return YES;
}

- (void) setupAppearance
{
    if (isIOS7) {
        [[UINavigationBar appearance] setBarTintColor:APP_COLOR_NAV_TINIT];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
        
        NSDictionary *attributes = @{UITextAttributeTextColor:[UIColor whiteColor]};
        [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    } else {
        [[UINavigationBar appearance] setTintColor:APP_COLOR_NAV_TINIT];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // we need to clear the badge when user come back to application
    [[PushManager manager] resetBadgeNumber:nil];
    
    if ([PFUser currentUser] && [[PFUser currentUser] isAuthenticated]) {
        
        if ([User currentUser] != nil) {
            
            [[User currentUser] refreshProfileWithCompletionHandler:nil];
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
							
- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[PushManager manager] setDeviceTokenFromData:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    DLog(@"failed to register remote notification : %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    // prior to iOS7 push implementation
    // if the app support background push, this function won't be called.
    
    DLog(@"application:didReceiveRemoteNotification");
    [[PushManager manager] handlePushMessage:userInfo CompletionHandler:nil];
    
    if (application.applicationState == UIApplicationStateInactive) {
        // the app is coming front by a push notification.
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    
    // iOS7 background push implementation
    
    if (application.applicationState == UIApplicationStateInactive) {
        // the app is coming front by a push notification.
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
    
    if (application.applicationState == UIApplicationStateInactive ||
        application.applicationState == UIApplicationStateActive) {
        [[PushManager manager] handlePushMessage:userInfo
                               CompletionHandler:^(BOOL success)
        {
            if (success)
                completionHandler(UIBackgroundFetchResultNewData);
            else
                completionHandler(UIBackgroundFetchResultFailed);
        }];
    }
    
}

#pragma mark Background Task
- (void) beginBackgroundTask
{
    [self endBackgroundTask];
    backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundTask];
    }];
}

- (void) endBackgroundTask
{
    if (backgroundTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    }
}

@end
