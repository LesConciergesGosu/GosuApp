//
//  CreateExperienceViewController.m
//  Gosu
//
//  Created by Dragon on 10/28/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "CreateExperienceViewController.h"
#import "NewTaskBaseViewController.h"
#import "NSString+Task.h"
#import "Experience+Extra.h"
#import "PTask.h"
#import "PCreditCard.h"
#import "AppAppearance.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface CreateExperienceViewController ()<NewTaskItemDelegate>


@property (nonatomic, strong) NSArray *taskTypes;
@property (nonatomic, strong) NSMutableArray *tasks;
@end

@implementation CreateExperienceViewController

+ (instancetype)createExperienceViewControllerWithTypes:(NSArray *)taskTypes
{
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:taskTypes];
    if ([array lastObject] == [NSNull null])
        [array removeLastObject];
    
    NSMutableArray *tasks = [NSMutableArray arrayWithCapacity:[array count]];
    for (NSInteger i = 0; i < [array count]; i ++)
         [tasks addObject:[NSNull null]];
    
    
    NSString *type = [array firstObject];
    NewTaskBaseViewController *rootVC = [NewTaskBaseViewController viewControllerWithType:[type mainType] subType:[type subType]];
    rootVC.taskIndex = 0;
    
    CreateExperienceViewController *res = [[CreateExperienceViewController alloc] initWithRootViewController:rootVC];
    res.taskTypes = array;
    res.tasks = tasks;
    [res setNavigationBarHidden:NO];
    [res.navigationBar setTranslucent:YES];
    [res.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [res.navigationBar setBackgroundColor:[UIColor clearColor]];
    
    rootVC.delegate = res;
    rootVC.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"CANCEL" style:UIBarButtonItemStyleBordered target:res action:@selector(onCancel:)];
    
    if ([array count] > 1)
        rootVC.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"NEXT" style:UIBarButtonItemStyleBordered target:rootVC action:@selector(onDone:)];
    else
        rootVC.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"DONE" style:UIBarButtonItemStyleBordered target:rootVC action:@selector(onDone:)];
    
    
    return res;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)onCancel:(id)sender
{
    if ([self.taskDelegate respondsToSelector:@selector(createExperienceViewControllerDidCancel:)])
    {
        [self.taskDelegate createExperienceViewControllerDidCancel:self];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)newTaskItemController:(NewTaskBaseViewController *)vc didFinishWithResult:(PTask *)result
{
    if (result != nil)
        [self.tasks replaceObjectAtIndex:vc.taskIndex withObject:result];
    
    NSInteger nextIndex = vc.taskIndex + 1;
    
    if (nextIndex >= [self.taskTypes count])
    {
        self.view.userInteractionEnabled = NO;
        [SVProgressHUD show];
        
        [self createTasksWithCompletion:^(BOOL success, NSString *errorDesc) {
            self.view.userInteractionEnabled = YES;
            [SVProgressHUD dismiss];
            
            if (success)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationCreatedNewTask object:nil];
                
                if ([self.taskDelegate respondsToSelector:@selector(createExperienceViewController:didFinishWithResult:)])
                {
                    [self.taskDelegate createExperienceViewController:self didFinishWithResult:success];
                }
                else
                {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }
            else
            {
                NSError *error = nil;
                
                if (errorDesc)
                    error = [[NSError alloc] initWithDomain:@"Gosu" code:0 userInfo:@{NSLocalizedFailureReasonErrorKey:errorDesc}];
                
                if ([self.taskDelegate respondsToSelector:@selector(createExperienceViewController:didFailWithError:)])
                {
                    [self.taskDelegate createExperienceViewController:self didFailWithError:error];
                }
                else
                {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }
        }];
    }
    else
    {
        
        NSString *type = [self.taskTypes objectAtIndex:nextIndex];
        NewTaskBaseViewController *nextVC = [NewTaskBaseViewController viewControllerWithType:[type mainType] subType:[type subType]];
        nextVC.minimumDate = result.date2 ?: result.date;
        nextVC.taskIndex = nextIndex;
        nextVC.delegate = self;
        nextVC.leftBarButtonItem = [AppAppearance backBarButtonItemWithTarget:nextVC action:@selector(onBack:)];
        if ([self.taskTypes count] > nextIndex + 1)
            nextVC.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"NEXT" style:UIBarButtonItemStyleBordered target:nextVC action:@selector(onDone:)];
        else
            nextVC.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"DONE" style:UIBarButtonItemStyleBordered target:nextVC action:@selector(onDone:)];
        [self pushViewController:nextVC animated:YES];
    }
}

- (void)createTasksWithCompletion:(GSuccessWithErrorBlock)completion
{
    [Experience createExperienceWithPFTasks:self.tasks completion:^(BOOL success, id pfObject, NSString *errorDesc) {
        completion(success, errorDesc);
    }];
}

@end
