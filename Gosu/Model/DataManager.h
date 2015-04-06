//
//  DataManager.h
//  Gosu
//
//  Created by dragon on 3/20/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject


@property (nonatomic,strong) NSManagedObjectContext * managedObjectContext;
@property (nonatomic,strong) NSPersistentStoreCoordinator   * persistentStoreCoordinator;

/**
 Return singletone instance.
 */
+ (DataManager *)manager;

- (void) setupParse;

#pragma mark Background Queue
- (void) runInBackgroundWithBlock:(void (^)(void))block;
- (void) runBlock:(void (^)(void))block inBackgroundWithIdentifier:(NSString *)identifier;

#pragma mark Login / Logout / Sign Up

- (void) autoLoginWithCompletionHandler:(GLoginBlock)completion;

- (void) loginWithUserName:(NSString *)userName
                  Password:(NSString *)password
         CompletionHandler:(GLoginBlock)completion;

- (void)signUpWithFirstName:(NSString *)firstName
                   LastName:(NSString *)lastName
                   UserName:(NSString *)userName
                      Email:(NSString *)email
                   Password:(NSString *)password
                       Type:(UserType)type
                      Photo:(UIImage *)photo
          CompletionHandler:(GLoginBlock)completion;

- (void) loginFacebookWithCompletionHandler:(GLoginBlock)completion;

- (void) updateUserProfileWithEmail:(NSString *)email
                          FirstName:(NSString *)firstName
                           LastName:(NSString *)lastName
                              Photo:(UIImage *)photo
                  CompletionHandler:(GSuccessWithErrorBlock)completion;

- (void) resetPasswordForEmail:(NSString *)email
             CompletionHandler:(GSuccessWithErrorBlock)completion;

- (void) logOut;
- (void) refreshTaskQueues;
- (void) refreshMyGosuListWithCompletionHandler:(GSuccessWithErrorBlock)completion;

/**
 Refresh the core data object from the Parse back end server.
 
 All Core Data Entities except for Tutorial.
 */
- (void) refreshObjectFromServer:(NSManagedObject *)managedObject
           withCompletionHandler:(GSuccessWithErrorBlock)completion;

#pragma mark File Download
- (void) loadImageBigURLRequest:(NSURLRequest *)request handler:(void (^)(UIImage *image))handler;
- (void) loadImageURLRequest:(NSURLRequest *)request handler:(void (^)(UIImage *image))handler;

#pragma mark - Speech Kit
- (/*SKRecognizer **/id)createSpeechKitRecognizerWithDelegate:(id)delegate;

#pragma mark - Core Data 
- (id) managedObjectWithID:(NSString *)ID withEntityName:(NSString *)entityName;
- (id) managedObjectWithID:(NSString *)ID withEntityName:(NSString *)entityName inContext:(NSManagedObjectContext *)context;
- (id) findObjectWithID:(NSString *)ID withEntityName:(NSString *)entityName inContext:(NSManagedObjectContext *)context;

- (void) saveMainContextAsynchronously;
- (void) saveMainContext;

@end
