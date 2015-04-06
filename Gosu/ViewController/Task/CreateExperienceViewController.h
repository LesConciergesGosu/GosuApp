//
//  CreateExperienceViewController.h
//  Gosu
//
//  Created by Dragon on 10/28/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CreateExperienceViewController;
@protocol CreateExperienceDelegate <NSObject>
- (void)createExperienceViewController:(CreateExperienceViewController *)vc didFinishWithResult:(BOOL)result;
- (void)createExperienceViewController:(CreateExperienceViewController *)vc didFailWithError:(NSError *)error;
- (void)createExperienceViewControllerDidCancel:(CreateExperienceViewController *)vc;
@end

@interface CreateExperienceViewController : UINavigationController

@property (nonatomic, weak) id<CreateExperienceDelegate> taskDelegate;
+ (instancetype)createExperienceViewControllerWithTypes:(NSArray *)taskTypes;
@end
