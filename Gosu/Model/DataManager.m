//
//  DataManager.m
//  Gosu
//
//  Created by dragon on 3/20/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "DataManager.h"
#import <CardIO/CardIO.h>
#import <CoreData/CoreData.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <AFNetworking/AFNetworking.h>
#import <libkern/OSAtomic.h>

#import "User+Extra.h"
#import "CreditCard+Extra.h"

#import "PFInstallation+Extra.h"
#import "PFUser+Extra.h"
#import "PCreditCard.h"
#import "PContract.h"
#import "PReview.h"
#import "PMessage.h"
#import "PTask.h"
#import "PUserProfile.h"
#import "PNotification.h"
#import "PGosu.h"
#import "DataManager.h"
#import "LocationManager.h"
#import <Reachability/Reachability.h>

static volatile int32_t singleTaskQueuesLock;

@interface DataManager()<SpeechKitDelegate>
{
    NSOperationQueue *queue;
    NSMutableDictionary *singleTaskQueues;
    BOOL _speechKitInitialized;
}

@property (nonatomic, strong) NSCache *cache;
@property (nonatomic,strong) NSManagedObjectModel           * managedObjectModel;
@end

@implementation DataManager

+ (DataManager *)manager
{
    static dispatch_once_t once;
    static DataManager *sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

+ (NSString *)cacheDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

- (id) init
{
    self = [super init];
    
    if (self)
    {
        _speechKitInitialized = NO;
        [self managedObjectContext];
    }
    
    return self;
}

- (NSOperationQueue *)queue {
    
    if (!queue) {
        queue = [[NSOperationQueue alloc] init];
        queue.name = @"Gosu Background Queue";
        queue.maxConcurrentOperationCount = 20;
    }
    
    return queue;
}

- (void) refreshTaskQueues
{
    while (singleTaskQueuesLock > 0) {
        [NSThread sleepForTimeInterval:0.1];
        continue;
    }
    
    OSAtomicAdd32(1, &singleTaskQueuesLock); {
        
        int removedCount = 0;
        
        NSArray *allKeys = [[singleTaskQueues allKeys] copy];
        
        for (NSString *key in allKeys) {
            NSOperationQueue *object = singleTaskQueues[key];
            if (object.operationCount == 0) {
                [singleTaskQueues removeObjectForKey:key];
                removedCount ++;
            }
        }
        
        DLog(@"removed %d operation queues", removedCount);
        
    }OSAtomicAdd32(-1, &singleTaskQueuesLock);
}

- (NSOperationQueue *)queueWithIdentifier:(NSString *)identifier {
    
    if (!identifier)
        return [self queue];
    
    while (singleTaskQueuesLock > 0) {
        [NSThread sleepForTimeInterval:0.1];
        continue;
    }
    
    NSOperationQueue *res = nil;
    
    OSAtomicAdd32(1, &singleTaskQueuesLock); {
        
        if (!singleTaskQueues)
            singleTaskQueues = [NSMutableDictionary dictionary];
        
        // get the operation with the identifier
        
        res = [singleTaskQueues objectForKey:identifier];
        
        if (res == nil) {
            res = [[NSOperationQueue alloc] init];
            res.name = identifier;
            res.maxConcurrentOperationCount = 1;
            
            [singleTaskQueues setObject:res forKey:identifier];
        }
        
        // clean the queue dictionary
        // remove the idle queue from the queue dictionary
        NSArray *allKeys = [[singleTaskQueues allKeys] copy];
        
        for (NSString *key in allKeys) {
            NSOperationQueue *object = singleTaskQueues[key];
            if (object != res && object.operationCount == 0) {
                [singleTaskQueues removeObjectForKey:key];
            }
        }
        
    } OSAtomicAdd32(-1, &singleTaskQueuesLock);
    
    return res;
}

- (void) runInBackgroundWithBlock:(void (^)(void))block {
    
    [[UIApplication sharedApplication] beganNetworkActivity];
    
    [[self queue] addOperationWithBlock:^{
        
        block();
        
        [[UIApplication sharedApplication] endNetworkActivity];
        
    }];
}

- (void) runBlock:(void (^)(void))block inBackgroundWithIdentifier:(NSString *)identifier{
    
    [[UIApplication sharedApplication] beganNetworkActivity];
    
    NSOperationQueue *operationQueue = [self queueWithIdentifier:identifier];
    
    [operationQueue addOperationWithBlock:^{
        
        DLog(@">>> '%@'", identifier);
        
        block();
        
        [[UIApplication sharedApplication] endNetworkActivity];
        
        
        DLog(@"<<< '%@'", identifier);
        
    }];
}

- (void) setupParse
{
    [PTask registerSubclass];
    [PContract registerSubclass];
    [PReview registerSubclass];
    [PCreditCard registerSubclass];
    [PMessage registerSubclass];
    [PGosu registerSubclass];
    [PUserProfile registerSubclass];
    [PNotification registerSubclass];
    
    [Parse setApplicationId:kParseAppID clientKey:kParseAppKey];
    [PFFacebookUtils initializeFacebook];
    
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [defaultACL setPublicWriteAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
}

#pragma mark Parse - Login/Signup/SignOut

- (void) autoLoginWithCompletionHandler:(GLoginBlock)completion {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, nil, @"Please check your internet connection.");
        return;
    } else if (![PFUser currentUser]) {
        completion(NO, nil, @"No previous login credentials.");
        return;
    }
    
    [self runBlock:^{
        
        NSError *error = nil;
        
        PFUser *pUser = [PFUser currentUser];
        [pUser refresh:&error];
        
        if (error == nil) {
            
            PFInstallation *installation = [PFInstallation currentInstallation];
            installation.currentUser = pUser;
            installation.userType = pUser.userType;
            [installation save];
            
            PFQuery *query = [PCreditCard query];
            [query whereKey:kParseCreditCardUserKey equalTo:pUser];
            [query orderByDescending:@"createdAt"];
            NSArray *pCards = [query findObjects];
            
            NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
            [context performBlock:^{
                
                [self checkPreviousLoginInContext:context];
                
                User *user = [User objectFromParseObject:pUser inContext:context];
                NSMutableArray *cards = [NSMutableArray arrayWithCapacity:[pCards count]];
                for (PCreditCard *pCard in pCards)
                    [cards addObject:[CreditCard objectFromParseObject:pCard inContext:context]];
                user.cards = [NSOrderedSet orderedSetWithArray:cards];
                
                if ([context hasChanges])
                    [context saveRecursively];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(YES, pUser, nil);
                    [self refreshMyGosuListWithCompletionHandler:nil];
                });
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, nil, ERROR_TO_STRING(error));
            });
        }
        
    } inBackgroundWithIdentifier:QueueInstallation];
}

- (void)loginWithUserName:(NSString *)userName
                 Password:(NSString *)password
        CompletionHandler:(GLoginBlock)completion {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, nil, @"Please check your internet connection.");
        return;
    }
    
    [self runBlock:^{
        
        NSError *error = nil;
        
        PFUser *pUser = [PFUser logInWithUsername:userName password:password error:&error];
        if (pUser != nil) {
            
            // check whether the user type is appropriate for the purpose of this app
            // customer or employee
            if ([pUser objectForKey:kParseUserTypeKey] && pUser.userType != USER_TYPE) {
                [PFUser logOut];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, nil, InvalidUserTypeMessage);
                });
                return;
            }
            PFInstallation *installation = [PFInstallation currentInstallation];
            installation.currentUser = pUser;
            installation.userType = pUser.userType;
            
            // reigster unique device identifier for the user.
            pUser[kParseUserInstallationKey] = installation;
            if ([LocationManager manager].currentLocation)
                pUser.location = [PFGeoPoint geoPointWithLocation:[LocationManager manager].currentLocation];
            
            [PFObject saveAll:@[installation, pUser] error:&error];
            
            PFQuery *query = [PCreditCard query];
            [query whereKey:kParseCreditCardUserKey equalTo:pUser];
            [query orderByDescending:@"createdAt"];
            NSArray *pCards = [query findObjects];
            
            NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
            [context performBlock:^{
                
                [self checkPreviousLoginInContext:context];
                
                User *user = [User objectFromParseObject:pUser inContext:context];
                NSMutableArray *cards = [NSMutableArray arrayWithCapacity:[pCards count]];
                for (PCreditCard *pCard in pCards)
                    [cards addObject:[CreditCard objectFromParseObject:pCard inContext:context]];
                user.cards = [NSOrderedSet orderedSetWithArray:cards];
                
                [context saveRecursively];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(YES, pUser, nil);
                    [self refreshMyGosuListWithCompletionHandler:nil];
                });
            }];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, nil, ERROR_TO_STRING(error));
                [self refreshMyGosuListWithCompletionHandler:nil];
            });
        }
        
    } inBackgroundWithIdentifier:QueueInstallation];
}

- (void)signUpWithFirstName:(NSString *)firstName
                   LastName:(NSString *)lastName
                   UserName:(NSString *)userName
                      Email:(NSString *)email
                   Password:(NSString *)password
                       Type:(UserType)type
                      Photo:(UIImage *)photo
          CompletionHandler:(GLoginBlock)completion {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, nil, @"Please check your internet connection.");
        return;
    }
    
    [self runBlock:^{
        
        PFUser *pUser = [PFUser user];
        pUser.firstName = firstName;
        pUser.lastName = lastName;
        pUser.username = userName;
        pUser.email = email;
        pUser.password = password;
        pUser.userType = type;
        pUser.hasProfile = YES;
        pUser.credits = DEF_CREDITS_COUNT;
        if ([LocationManager manager].currentLocation)
            pUser.location = [PFGeoPoint geoPointWithLocation:[LocationManager manager].currentLocation];
        
        NSError *error = nil;
        
        if ([pUser signUp:&error]) {
            
            // check for the multiple account creation
            // maximum 3 times MAX_ACCOUNT_CREATION_COUNT
            
            BOOL isValidForAccountCreation = YES;
            
            PFInstallation *installation = [PFInstallation currentInstallation];
            if (![installation isDirty]) {
                PFQuery *query = [PFUser query];
                [query whereKey:kParseUserInstallationKey equalTo:installation];
                
                if ([query countObjects] > MAX_ACCOUNT_CREATION_COUNT) {
                    isValidForAccountCreation = NO;
                }
            }
            
            if (!isValidForAccountCreation) {
                [pUser deleteEventually];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, nil, @"You tried to sign up with different credentials more than 3 times. You're not allowed to sign up more.");
                });
                return;
            }
            
            installation = [PFInstallation currentInstallation];
            installation.currentUser = [PFUser currentUser];
            installation.userType = type;
            
            if (photo) {
                PFFile *file = [PFFile fileWithName:@"photo.jpg" data:UIImageJPEGRepresentation(photo, 1)];
                
                if ([file save:&error]) {
                    pUser.photo = file;
                }
            }
            
            pUser[kParseUserInstallationKey] = installation;
            [PFObject saveAll:@[installation, pUser] error:&error];
            
            NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
            [context performBlock:^{
                
                [self checkPreviousLoginInContext:context];
                
                [User objectFromParseObject:pUser inContext:context];
                
                [context saveRecursively];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(YES, pUser, error ? [error displayString] : nil);
                    [self refreshMyGosuListWithCompletionHandler:nil];
                });
            }];
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, nil, ERROR_TO_STRING(error));
            });
        }
    } inBackgroundWithIdentifier:QueueInstallation];
}

- (void) loginFacebookWithCompletionHandler:(GLoginBlock)completion
{
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, nil, @"Please check your internet connection.");
        return;
    }
    
    NSArray *permissions = @[@"basic_info", @"email", @"public_profile", @"user_friends"];
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *pUser, NSError *error) {
        
        if (!pUser) {
            
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, nil, @"You cancelled the Facebook login.");
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, nil, @"Failed to connect to facebook.com, you may need to log out from the Settings > Facebook on your phone.");
                });
            }
            
        } else {
            
            // check whether the user type is appropriate for the purpose of this app
            // customer or employee
            if ([pUser objectForKey:kParseUserTypeKey] && pUser.userType != USER_TYPE) {
                [PFUser logOut];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, nil, InvalidUserTypeMessage);
                });
                return;
            }
            
            BOOL isValidForAccountCreation = YES;
            
            PFInstallation *installation = [PFInstallation currentInstallation];
            
            if (![installation isDirty]) {
                PFQuery *query = [PFUser query];
                [query whereKey:kParseUserInstallationKey equalTo:[PFInstallation currentInstallation]];
                
                if ([query countObjects] > MAX_ACCOUNT_CREATION_COUNT) {
                    isValidForAccountCreation = NO;
                }
            }
            
            if (!isValidForAccountCreation) {
                [pUser deleteEventually];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, nil, @"You tried to sign up with different credentials more than 3 times. You're not allowed to sign up more.");
                });
                return;
            }
            
            installation = [PFInstallation currentInstallation];
            installation.currentUser = [PFUser currentUser];
            installation.userType = USER_TYPE;
            
            [FBSession setActiveSession:[PFFacebookUtils session]];
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> result, NSError *error) {
                
                if (result) {
                // fetched user information from facebook.
                    
                    // reigster unique device identifier for the user.
                    pUser[kParseUserInstallationKey] = installation;
                    
                    // set other profile information
                    pUser.firstName = [result first_name];
                    pUser.lastName = [result last_name];
                    pUser.email = [result objectForKey:@"email"] ? [result objectForKey:@"email"] : @"";
                    pUser.hasProfile = YES;
                    pUser.userType = USER_TYPE;
                    
                    if ([LocationManager manager].currentLocation)
                        pUser.location = [PFGeoPoint geoPointWithLocation:[LocationManager manager].currentLocation];
                    
                    if (![pUser objectForKey:kParseUserCreditsVKey])
                        pUser.credits = DEF_CREDITS_COUNT;
                    
                    [FBRequestConnection startWithGraphPath:@"/me/picture" parameters:@{@"redirect":@"0", @"height":@"120", @"width":@"120", @"type":@"normal"} HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id<FBGraphObject> result, NSError *error) {
                        
                        NSString *url;
                        if ((url = [result[@"data"] objectForKey:@"url"])) {
                            
                            [self runInBackgroundWithBlock:^{
                                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                                if (data) {
                                    PFFile *file = [PFFile fileWithData:data];
                                    [file save];
                                    
                                    // set photo to the user
                                    pUser.photo = file;
                                    
                                    [PFObject saveAll:@[installation, pUser]];
                                }
                                
                                PFQuery *query = [PCreditCard query];
                                [query whereKey:kParseCreditCardUserKey equalTo:pUser];
                                [query orderByDescending:@"createdAt"];
                                NSArray *pCards = [query findObjects];
                                
                                NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
                                [context performBlock:^{
                                    
                                    [self checkPreviousLoginInContext:context];
                                    
                                    User *user = [User objectFromParseObject:pUser inContext:context];
                                    NSMutableArray *cards = [NSMutableArray arrayWithCapacity:[pCards count]];
                                    for (PCreditCard *pCard in pCards)
                                        [cards addObject:[CreditCard objectFromParseObject:pCard inContext:context]];
                                    user.cards = [NSOrderedSet orderedSetWithArray:cards];
                                    
                                    [context saveRecursively];
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        completion(YES, pUser, error ? [error displayString] : nil);
                                        [self refreshMyGosuListWithCompletionHandler:nil];
                                    });
                                }];
                            }];
                            
                        } else {
                            // can't get the photo of the user from his/her wall.
                            
                            [self runBlock:^{
                                
                                [PFObject saveAll:@[installation, pUser]];
                                
                                PFQuery *query = [PCreditCard query];
                                [query whereKey:kParseCreditCardUserKey equalTo:pUser];
                                [query orderByDescending:@"createdAt"];
                                NSArray *pCards = [query findObjects];
                                
                                NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
                                [context performBlock:^{
                                    
                                    User *user = [User objectFromParseObject:pUser inContext:context];
                                    NSMutableArray *cards = [NSMutableArray arrayWithCapacity:[pCards count]];
                                    for (PCreditCard *pCard in pCards)
                                        [cards addObject:[CreditCard objectFromParseObject:pCard inContext:context]];
                                    user.cards = [NSOrderedSet orderedSetWithArray:cards];
                                    
                                    [context saveRecursively];
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        completion(YES, pUser, error ? [error displayString] : nil);
                                        [self refreshMyGosuListWithCompletionHandler:nil];
                                    });
                                }];
                                
                            } inBackgroundWithIdentifier:QueueInstallation];
                        }
                    }];
                    
                } else {
                // cannot fetch user information from facebook.
                    
                    [self runBlock:^{
                        
                        PFQuery *query = [PCreditCard query];
                        [query whereKey:kParseCreditCardUserKey equalTo:pUser];
                        [query orderByDescending:@"createdAt"];
                        NSArray *pCards = [query findObjects];
                        
                        NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
                        [context performBlock:^{
                            
                            User *user = [User objectFromParseObject:pUser inContext:context];
                            NSMutableArray *cards = [NSMutableArray arrayWithCapacity:[pCards count]];
                            for (PCreditCard *pCard in pCards)
                                [cards addObject:[CreditCard objectFromParseObject:pCard inContext:context]];
                            user.cards = [NSOrderedSet orderedSetWithArray:cards];
                            
                            [context saveRecursively];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completion(YES, pUser, error ? [error displayString] : nil);
                                [self refreshMyGosuListWithCompletionHandler:nil];
                            });
                        }];
                        
                    } inBackgroundWithIdentifier:QueueInstallation];
                }
            }];
        }
    }];
}

- (void) updateUserProfileWithEmail:(NSString *)email
                          FirstName:(NSString *)firstName
                           LastName:(NSString *)lastName
                              Photo:(UIImage *)photo
                  CompletionHandler:(GSuccessWithErrorBlock)completion {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, @"Please check your internet connection.");
        return;
    }
    
    PFUser *pUser = [PFUser currentUser];
    if (email)
        pUser.email = email;
    if (firstName)
        pUser.firstName = firstName;
    if (lastName)
        pUser.lastName = lastName;
    
    [self runInBackgroundWithBlock:^{
        
        NSString *photoUrl = nil;
        NSError *error = nil;
        
        if (photo) {
            
            PFFile *file = [PFFile fileWithName:@"photo.jpg"
                                           data:UIImageJPEGRepresentation(photo, 1)];
            if ([file save:&error]) {
                pUser.photo = file;
                photoUrl = [file url];
            }
        }
        
        if ([pUser save:&error]) {
            
            NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
            
            [context performBlock:^{
                User *user;
                
                NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
                [request setPropertiesToFetch:@[@"email", @"userType", @"photo"]];
                [request setPredicate:[NSPredicate predicateWithFormat:@"objectId == %@", pUser.objectId]];
                user = [[context executeFetchRequest:request error:nil] firstObject];
                
                user.email = email;
                user.userType = @(pUser.userType);
                
                if (photoUrl)
                    user.photo = photoUrl;
                
                [context saveRecursively];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(YES, nil);
                });
            }];
            
        } else  {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, ERROR_TO_STRING(error));
            });
            
        }
        
    }];
}

- (void) logOut
{
    PFUser *pUser = [PFUser currentUser];
    
    if (pUser) {
        
        // clear Installation
        [self runBlock:^{
            
            PFInstallation *installation = [PFInstallation currentInstallation];
            
            [installation removeObjectForKey:kParseInstallationUserKey];
            [installation removeObjectForKey:kParseInstallationUserTypeKey];
            
            [installation save];
            
        } inBackgroundWithIdentifier:QueueInstallation];
        
        [PFQuery clearAllCachedResults];
        [PFUser logOut];
    }
    
    // logout broadcast notification
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationLoggedOut object:nil];
}

- (void) checkPreviousLoginInContext:(NSManagedObjectContext *)context {
    
    PFUser *user = [PFUser currentUser];
    
    NSString *lastLoggedInUserID = [[NSUserDefaults standardUserDefaults] objectForKey:kLastLoggedInUser];
    if (lastLoggedInUserID != nil && ![user.objectId isEqualToString:lastLoggedInUserID]) {
        //drop previous tables.
        [self removeAllCoreDataObjectsFromContext:context];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastFetchUnreadMessages];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:user.objectId forKey:kLastLoggedInUser];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Reset Password

- (void) resetPasswordForEmail:(NSString *)email
             CompletionHandler:(GSuccessWithErrorBlock)completion
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        completion(NO, @"Please check your internet connection.");
        return;
    }
    
    [self runInBackgroundWithBlock:^{
        
        NSError *error = nil;
        [PFCloud callFunction:@"resetPassword" withParameters:@{@"email":email} error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error) {
                completion(NO, [error displayString]);
            } else {
                completion(YES, nil);
            }
        });
    }];
}

#pragma mark My Gosu List

- (void) refreshMyGosuListWithCompletionHandler:(GSuccessWithErrorBlock)completion {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        
        if (completion) completion(NO, @"Please check your internet connection.");
        return;
    } else if (![PFUser currentUser]) {
        if (completion) completion(NO, @"Not logged in yet.");
        return;
    }
    
    [self runInBackgroundWithBlock:^{
        
        PFQuery *query = [PGosu query];
        [query whereKey:@"from" equalTo:[PFUser currentUser]];
        
        NSError *error = nil;
        NSArray *array = [query findObjects:&error];
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(NO, ERROR_TO_STRING(error));
            });
            return;
        }
        
        NSMutableArray *gosuIds = [NSMutableArray array];
        
        for (PGosu *gosuRelation in array) {
            [gosuIds addObject:gosuRelation.to.objectId];
        }
        
        NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
        
        [context performBlock:^{
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
            [request setPredicate:[NSPredicate predicateWithFormat:@"myGosu == %@ AND NOT (objectId IN %@)", @(YES), gosuIds]];
            NSArray *array = [context executeFetchRequest:request error:nil];
            for (User *user in array) {
                user.myGosu = @(NO);
            }
            
            for (NSString *userId in gosuIds) {
                User *user = [self managedObjectWithID:userId withEntityName:@"User" inContext:context];
                if (![user.myGosu boolValue])
                    user.myGosu = @(YES);
            }
            
            if ([context hasChanges]) {
                [context saveRecursively];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion)
                        completion(YES, nil);
                    else
                        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationMyGosuListUpdated object:nil];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion(NO, nil);
                });
            }
        }];
    }];
}

#pragma mark Refresh Object

- (void) refreshObjectFromServer:(NSManagedObject *)managedObject
           withCompletionHandler:(GSuccessWithErrorBlock)completion {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
        if (completion) completion(NO, @"Please check your internet connection.");
        return;
    }
    
    NSString *className = NSStringFromClass([managedObject class]);
    NSString *parseObjectId;
    
    if ([managedObject respondsToSelector:@selector(objectId)]) {
        parseObjectId = [managedObject performSelector:@selector(objectId)];
    } else {
        if (completion) completion(NO, [NSString stringWithFormat:@"Trying to pull an invalid object : %@", managedObject]);
        return;
    }
    
    [self runInBackgroundWithBlock:^{
        
        NSError *error = nil;
        PFObject *pObject = [PFObject objectWithoutDataWithClassName:className
                                                            objectId:parseObjectId];
        [pObject refresh:&error];
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(NO, nil);
            });
        } else {
            
            NSManagedObject *object = [self managedObjectWithID:parseObjectId withEntityName:className];
            
            if ([object respondsToSelector:@selector(fillInFromParseObject:)])
                [object performSelector:@selector(fillInFromParseObject:) withObject:pObject];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion)
                    completion(YES, nil);
            });
        }
    }];
}

#pragma mark Image Download
- (void) loadImageURLRequest:(NSURLRequest *)request handler:(void (^)(UIImage *image))handler {
    
    UIImage *cachedImage = [[UIImageView sharedImageCache] cachedImageForRequest:request];
    if (cachedImage) {
        if (handler)
            handler(cachedImage);
        return;
    }
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (handler) {
            handler(responseObject);
        }
        
        [[UIImageView sharedImageCache] cacheImage:responseObject forRequest:request];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (handler)
            handler(nil);
        
    }];
    
    [[self queue] addOperation:operation];
}

#pragma mark - Speech Kit
- (SKRecognizer *)createSpeechKitRecognizerWithDelegate:(id<SKRecognizerDelegate>)delegate {
    if (!_speechKitInitialized) {
        [SpeechKit setupWithID:SpeechKitAppID
                          host:SpeechKitHostAddress
                          port:SpeechKitHostPort
                        useSSL:NO
                      delegate:self];
        
        SKEarcon* earconStart	= [SKEarcon earconWithName:@"earcon_listening.wav"];
        SKEarcon* earconStop	= [SKEarcon earconWithName:@"earcon_done_listening.wav"];
        SKEarcon* earconCancel	= [SKEarcon earconWithName:@"earcon_cancel.wav"];
        
        [SpeechKit setEarcon:earconStart forType:SKStartRecordingEarconType];
        [SpeechKit setEarcon:earconStop forType:SKStopRecordingEarconType];
        [SpeechKit setEarcon:earconCancel forType:SKCancelRecordingEarconType];
    }
    
    SKRecognizer *voiceSearch
                = [[SKRecognizer alloc] initWithType:SKSearchRecognizerType
                                           detection:SKNoEndOfSpeechDetection
                                            language:@"en_US"
                                            delegate:delegate];
    return voiceSearch;
}

#pragma mark - Core Data

- (void) removeAllCoreDataObjectsFromContext:(NSManagedObjectContext *)context
{
    NSError *error;
    NSArray *entities = self.managedObjectModel.entities;
    
    for (NSEntityDescription *entity in entities) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setIncludesPendingChanges:NO];
        
        NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
        error = nil;
        for (NSManagedObject *managedObject in items) {
            [managedObject.managedObjectContext deleteObject:managedObject];
        }
    }
    
    [context processPendingChanges];
}

- (id) findObjectWithID:(NSString *)ID withEntityName:(NSString *)entityName inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    [request setPredicate:[NSPredicate predicateWithFormat:@"objectId == %@", ID]];
    
    NSArray *array = [context executeFetchRequest:request error:nil];
    
    return [array firstObject];
}

- (id) managedObjectWithID:(NSString *)ID withEntityName:(NSString *)entityName
{
    return [self managedObjectWithID:ID withEntityName:entityName inContext:self.managedObjectContext];
}

- (id) managedObjectWithID:(NSString *)ID withEntityName:(NSString *)entityName inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    [request setPredicate:[NSPredicate predicateWithFormat:@"objectId == %@", ID]];
    [request setFetchLimit:1];
    NSArray *array = [context executeFetchRequest:request error:nil];
    
    if ([array count] > 0)
        return array[0];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:context];
    
    Class class = NSClassFromString(entityName);
    id res = [[class alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    [(NSManagedObject *)res setValue:ID forKey:@"objectId"];
    
    return res;
}

- (NSManagedObjectContext *)managedObjectContext {
    
	if(!_managedObjectContext) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _managedObjectContext.mergePolicy = [[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyStoreTrumpMergePolicyType];
        _managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    
	return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    
	if(!_managedObjectModel)
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
	return _managedObjectModel;
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
	if(!_persistentStoreCoordinator) {
        
        NSString * appSupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        BOOL dirExists = [[NSFileManager defaultManager] fileExistsAtPath:appSupportDirectory];
        if (dirExists == NO) {
            [[NSFileManager defaultManager] createDirectoryAtPath:appSupportDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        
        NSURL *appSupportURL = [NSURL URLWithString:appSupportDirectory];
        [appSupportURL setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:nil];
        
        NSString *storePath = [appSupportDirectory stringByAppendingPathComponent:@"Gosu.sqlite"];
        NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
        
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@(YES),
                                  NSInferMappingModelAutomaticallyOption:@(YES),
                                  NSSQLitePragmasOption:@{@"journal_mode":@"WAL"}};
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        
        NSError *error = nil;
        if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
            
            DLog(@"Error loading persistent store: %@", error);
            
            NSError *removeError;
            
            if ([[NSFileManager defaultManager] removeItemAtPath:storePath error:&removeError]) {
                
                if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
                    DLog(@"Error re-adding persistent store: %@", error);
                }
                else {
                    DLog(@"Removed previous store and re-added clean one.");
                }
                
            }
            else
                DLog(@"Error re-adding persistent store: %@", removeError);
        }
    }
	
    return _persistentStoreCoordinator;
}

- (void) saveMainContextAsynchronously {
    
    [self.managedObjectContext performBlock:^{
        
        NSError *error;
        [self.managedObjectContext save:&error];
        if (error) {
            DLog(@"Error saving MAIN Context");
        }
        [self.managedObjectContext processPendingChanges];
    }];
}

- (void) saveMainContext
{
    [self.managedObjectContext performBlockAndWait:^{
        
        NSError *error;
        [self.managedObjectContext save:&error];
        if (error) {
            DLog(@"Error saving MAIN Context");
        }
        [self.managedObjectContext processPendingChanges];
    }];
}

@end
