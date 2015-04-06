//
//  Common.h
//  Gosu
//
//  Created by dragon on 3/19/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//
#ifndef GOSU_COMMON_H
#define GOSU_COMMON_H
//==============================================================================
#pragma mark - Debug Log Macros
#ifdef DEBUG
#define DLog(__FORMAT__, ...) NSLog((@"<%@:%d> " __FORMAT__), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, ##__VA_ARGS__)
#define ALog(...) [[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding] file:[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lineNumber:__LINE__ description:__VA_ARGS__]
#else
#define DLog(...) do {} while (0)
#define ALog(__FORMAT__, ...) NSLog((@"<%@:%d> " __FORMAT__), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, ##__VA_ARGS__)
#endif


#pragma mark - App keys
FOUNDATION_EXPORT NSString *const kCardIOAppTocken;
FOUNDATION_EXPORT NSString *const kParseAppID;
FOUNDATION_EXPORT NSString *const kParseAppKey;
FOUNDATION_EXPORT const unsigned char SpeechKitApplicationKey[];
FOUNDATION_EXPORT NSString *const SpeechKitAppID;
FOUNDATION_EXPORT NSString *const SpeechKitHostAddress;
FOUNDATION_EXPORT const long SpeechKitHostPort;
#define MIXPANEL_TOKEN @"c662313453ed0b6d38e6c7c4e4676882"

#pragma mark - App Type

//#define APP_TYPE_CUSTOMER
FOUNDATION_EXPORT NSString *const InvalidUserTypeMessage;

#ifdef APP_TYPE_CUSTOMER
#define USER_TYPE UserTypeCustomer
#else
#define USER_TYPE UserTypeEmployee
#endif


#ifdef DEBUG
#define ENABLE_EMPLOYEE
#endif

#pragma mark - Device & Appearance

#define isIOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define APP_COLOR_NAV_TINIT [UIColor colorWithRed:26/255.f green:31/255.f blue:37/255.f alpha:1]
#define APP_COLOR_GREEN     [UIColor colorWithRed:55/255.f green:188/255.f blue:155/255.f alpha:1]
#define APP_COLOR_TEXT_BLACK    [UIColor colorWithRed:26/255.f green:31/255.f blue:37/255.f alpha:1]
#define APP_COLOR_TEXT_GRAY    [UIColor colorWithRed:157/255.f green:159/255.f blue:163/255.f alpha:1]
#define APP_COLOR_BACKGROUND [UIColor whiteColor]

#define DEF_CREDITS_COUNT   10
#define MAX_ACCOUNT_CREATION_COUNT 3
#define MAX_MESSAGES_LOADED_ONCE 100
#define ERROR_TO_STRING(e) e ? [e displayString] : @"Unkown Error"


#pragma mark - Types

typedef NS_ENUM(NSInteger, SideMenuAction) {
    SideMenuActionHome,
    SideMenuActionJobBoard,
    SideMenuActionProfile,
    SideMenuActionPayment,
    SideMenuActionLogOut,
    SideMenuActionCount,
    SideMenuActionNotification
};

typedef NS_ENUM(NSInteger, UserType) {
    UserTypeCustomer,
    UserTypeEmployee
};

typedef NS_ENUM(NSInteger, TaskStatus) {
    TaskStatusCreated = 0,  // the customer has requested the task
    TaskStatusAssigned,     // System assigned this task to a gosu
    TaskStatusFinished,    // the Gosu has delivered the task
    TaskStatusReviewed,     // the customer has reviewed on the task.
    TaskStatusCount
};

// as possible, we need to keep same value as TaskStatus
typedef NS_ENUM(NSInteger, ContractStatus) {
    ContractStatusOpen = 1, // same as Task Status Assigned
    ContractStatusFinished, // same as Task Status Delivered
    ContractStatusReviewed,
    ContractStatusCancelled,
    ContractStatusLimit
};

typedef NS_ENUM(NSInteger, ContractRole) {
    ContractRoleInformation, //Information Worker
    ContractRoleMain, //
};

typedef NS_ENUM(NSInteger, MessageType) {
    MessageTypeText,
    MessageTypePhoto,
    MessageTypeAudio,
    // reserve 3 ~ 8 for the future purpose
    MessageTypeNotification = 9,
    MessageTypeDescription = 10,
    MessageTypeCount
};

typedef NS_ENUM(NSInteger, MessageStatus) {
    MessageStatusCreated = 0,
    MessageStatusNotDelivered,
    MessageStatusDelivered,
    MessageStatusRead
};

typedef NS_ENUM(NSInteger, NotificationStatus) {
    NotificationStatusUnread = 0,
    NotificationStatusRead
};

typedef NS_ENUM(NSInteger, PushType) {
    PushTypeMessage = 0,
    PushTypeTaskCreated = 10,
    PushTypeTaskAccepted = 11,
    PushTypeTaskDelivered = 12,
    PushTypeTaskReviewed = 13,
    PushTypeTaskResigned = 14,
    PushTypeTaskReview = 15,
    PushTypeGetReviewed = 20,
};

typedef NS_ENUM(NSInteger, PersonRelation) {
    PersonRelationDad,
    PersonRelationMom,
    PersonRelationBrother,
    PersonRelationSister,
    PersonRelationFamily,
    PersonRelationFriend,
};

typedef NS_ENUM(NSInteger, ProfileAccessType) {
    ProfileAccessTypePublic,
    ProfileAccessTypeOnlyWorkers,
    ProfileAccessTypeOnlyGosu,
    ProfileAccessTypePrivate
};

typedef NS_ENUM(NSInteger, VoiceRecordingState) {
    VR_IDLE,
    VR_INITIAL,
    VR_RECORDING,
    VR_PROCESSING
};

FOUNDATION_EXPORT NSString *const QueueInstallation;
FOUNDATION_EXPORT NSString *const QueueGosuList;
FOUNDATION_EXPORT NSString *const QueueProfile;
FOUNDATION_EXPORT NSString *const QueueNotificationList;

FOUNDATION_EXPORT NSString *const kLastLoggedInUser;
FOUNDATION_EXPORT NSString *const kLastFetchUnreadMessages;

#pragma mark - Parse Cloud Functions
FOUNDATION_EXPORT NSString *const CloudAcceptTask;
FOUNDATION_EXPORT NSString *const CloudDeliverTask;
FOUNDATION_EXPORT NSString *const CloudResignTask;
FOUNDATION_EXPORT NSString *const CloudEditTaskDescription;
FOUNDATION_EXPORT NSString *const CloudGetJobs;
FOUNDATION_EXPORT NSString *const CloudGetReviewListTodo;
FOUNDATION_EXPORT NSString *const CloudRateExperiences;
FOUNDATION_EXPORT NSString *const CloudIgnoreJobPosting;
FOUNDATION_EXPORT NSString *const CloudFetchNewMessageCounts;

#pragma mark - Notifications
FOUNDATION_EXPORT NSString *const NotificationMyGosuListUpdated;
FOUNDATION_EXPORT NSString *const NotificationCardAdded;
FOUNDATION_EXPORT NSString *const NotificationLoadNewTask;
FOUNDATION_EXPORT NSString *const NotificationCreatedNewTask;
FOUNDATION_EXPORT NSString *const NotificationRefreshTaskListView;
FOUNDATION_EXPORT NSString *const NotificationLoggedOut;
FOUNDATION_EXPORT NSString *const NotificationLoggedIn;
FOUNDATION_EXPORT NSString *const NotificationReviewedTask;
FOUNDATION_EXPORT NSString *const NotificationUpdatedUnreadMessageCounts;
FOUNDATION_EXPORT NSString *const NotificationNotificationListUpdated;


#pragma mark - Parse Installation Class
FOUNDATION_EXPORT NSString *const kParseInstallationUserKey;
FOUNDATION_EXPORT NSString *const kParseInstallationUserTypeKey;

#pragma mark - Parse User Class
// Field Keys

typedef NS_ENUM(NSInteger, PersonalInfoType) {
    PersonalInfoTypeAddress,
    PersonalInfoTypeBirthday,
    PersonalInfoTypePassport,
    PersonalInfoTypeOther = 10
};

#pragma mark - Blocks

typedef void (^VoidBlock)();
typedef void (^GSuccessBlock)(BOOL success);
typedef void (^GSuccessWithErrorBlock)(BOOL success, NSString *errorDesc);
typedef void (^GLoginBlock)(BOOL success, id user, NSString *errorDesc);
typedef void (^GCreateObjectBlock)(BOOL success, id object, NSString *errorDesc);
typedef void (^GArrayBlock)(NSArray *array, NSString *errorDesc);
typedef void (^GDictionaryBlock)(NSDictionary *dictionary, NSString *errorDesc);
typedef void (^GIntBlock)(NSInteger value, NSString *errorDesc);

#pragma mark - inline functions

NSString *getUUID();

NSString * generateNewFileAtDirectory(NSString *directory, NSString *prefix, NSString *extension);

NSString *generateNewTemporaryFile(NSString *extension);

#endif

