//
//  Common.m
//  Gosu
//
//  Created by dragon on 3/19/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//
#import "Common.h"

#pragma mark - App Keys
NSString *const kCardIOAppTocken = @"d445a7140a4d417197c78f0f8401d978";
#ifdef DEBUG
NSString *const kParseAppID = @"uai2QtrljgETwCJCJcUuinO0FBhJsRYueiYfcnHb";
NSString *const kParseAppKey = @"gDvLSs1LVUCkPKCZmxGxzmByIIqSh5Z1w4kvoyGR";
#else
NSString *const kParseAppID = @"64rSEPH9QSUXeNEOl1Dk8mu6SDSD08riPlXGqeUU";
NSString *const kParseAppKey = @"FiDb6HSOKRr2RBToPChuXaNRJOjsrqM8HUqnN5oj";
#endif
const unsigned char SpeechKitApplicationKey[] =
{
    0x31, 0x11, 0x88, 0xe7, 0xca, 0x66, 0xcb, 0xeb, 0x81, 0x6b,
    0x13, 0x23, 0x62, 0x24, 0x64, 0x9b, 0x0c, 0x0a, 0x51, 0x38,
    0x2b, 0x95, 0xdb, 0x5c, 0x40, 0x98, 0x93, 0x6d, 0x97, 0x61,
    0x65, 0xc8, 0x72, 0xed, 0xaf, 0x3c, 0x53, 0x7a, 0x27, 0xd5,
    0xe5, 0x3a, 0xf8, 0x47, 0x5f, 0x5d, 0xe2, 0x6b, 0x67, 0x33,
    0xa3, 0x92, 0xc8, 0x7e, 0xef, 0x08, 0x16, 0x82, 0x75, 0xad,
    0xe4, 0xda, 0x75, 0x56
};
NSString *const SpeechKitAppID = @"NMDPTRIAL_mattclemenson20140501021542";
NSString *const SpeechKitHostAddress = @"sandbox.nmdp.nuancemobility.net";
const long SpeechKitHostPort = 443;

#pragma mark - App Type
#ifdef APP_TYPE_CUSTOMER
NSString *const InvalidUserTypeMessage = @"This app is for customers only.";
#else
NSString *const InvalidUserTypeMessage = @"This app is for employees only.";
#endif

NSString *const QueueInstallation = @"Installation";
NSString *const QueueGosuList = @"GosuList";
NSString *const QueueProfile = @"Profile";
NSString *const QueueNotificationList = @"NotificationList";

NSString *const kLastLoggedInUser = @"LastLoggedInUser";
NSString *const kLastFetchUnreadMessages = @"LastFetchUnreadMessages";

#pragma mark - Cloud Functions
NSString *const CloudAcceptTask = @"acceptTask";
NSString *const CloudDeliverTask = @"deliverTask";
NSString *const CloudResignTask = @"resignTask";
NSString *const CloudEditTaskDescription = @"editTaskDescription";
NSString *const CloudGetJobs = @"getJobs";
NSString *const CloudGetReviewListTodo = @"getReviewsTodoInTask";
NSString *const CloudRateExperiences = @"rateExperienceInTask";
NSString *const CloudIgnoreJobPosting = @"ignoreTask";
NSString *const CloudFetchNewMessageCounts = @"fetchNewMessageCounts";

#pragma mark - Notifications
NSString *const NotificationMyGosuListUpdated = @"NotificationMyGosuListUpdated";
NSString *const NotificationCardAdded = @"NotificationCardAdded";
NSString *const NotificationLoadNewTask = @"NotificationLoadNewTask";
NSString *const NotificationCreatedNewTask = @"NotificationCreatedNewTask";
NSString *const NotificationRefreshTaskListView = @"NotificationRefreshTaskListView";
NSString *const NotificationLoggedOut = @"NotificationLoggedOut";
NSString *const NotificationLoggedIn = @"NotificationLoggedIn";
NSString *const NotificationReviewedTask = @"NotificationReviewedTask";
NSString *const NotificationUpdatedUnreadMessageCounts = @"NotificationUpdatedUnreadMessageCounts";
NSString *const NotificationNotificationListUpdated = @"NotificationNotificationListUpdated";

NSString *const kParseInstallationUserKey = @"user";
NSString *const kParseInstallationUserTypeKey = @"userType";

#pragma mark inline functions
NSString *getUUID()
{
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
	CFStringRef newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    
#if !__has_feature(objc_arc)
    NSString *res = [NSString stringWithString:(NSString *)newUniqueIdString];
#else
    NSString *res = [NSString stringWithString:(__bridge NSString *)newUniqueIdString];
#endif
	CFRelease(newUniqueId);
	CFRelease(newUniqueIdString);
    
    return res;
}

NSString * generateNewFileAtDirectory(NSString *directory, NSString *prefix, NSString *extension)
{
    
    NSString *path = directory;
    
    //Create unique filename
	CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
	CFStringRef newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    if (prefix)
#if !__has_feature(objc_arc)
        path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", prefix, (NSString *)newUniqueIdString]];
#else
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", prefix, (__bridge NSString *)newUniqueIdString]];
#endif
	
    
    if (extension)
        path = [path stringByAppendingPathExtension: extension];
	CFRelease(newUniqueId);
	CFRelease(newUniqueIdString);
    
    return path;
}

NSString *generateNewTemporaryFile(NSString *extension)
{
    return generateNewFileAtDirectory(NSTemporaryDirectory(), @"", extension);
}