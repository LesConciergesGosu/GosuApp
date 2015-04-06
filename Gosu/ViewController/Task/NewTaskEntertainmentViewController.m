//
//  NewTaskEntertainmentViewController.m
//  Gosu
//
//  Created by Dragon on 10/15/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "NewTaskEntertainmentViewController.h"
#import "PTask.h"

@interface NewTaskEntertainmentViewController ()

@end

@implementation NewTaskEntertainmentViewController

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
    
    if ([self.subTaskType isEqualToString:TASK_TYPE_SPORTS])
    {
        self.txtSubType.placeholder = @"Name your team or sport";
    }
    else if ([self.subTaskType isEqualToString:TASK_TYPE_THEATRE])
    {
        self.txtSubType.placeholder = @"What type of show?";
    }
    else if ([self.subTaskType isEqualToString:TASK_TYPE_CONCERTS])
    {
        self.txtSubType.placeholder = @"What type of music are you into?";
    }
    else if ([self.subTaskType isEqualToString:TASK_TYPE_MOVIE])
    {
        self.txtSubType.placeholder = @"What type of movie?";
    }
    else //if ([self.taskType isEqualToString:TASK_TYPE_NIGHTLIFE])
    {
        self.txtSubType.placeholder = @"What type of event are you looking for?";
    }
        
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Overridden methods

- (NSString *)errorMessageForInvalidInputs
{
    
    if ([self.txtCity text].length == 0)
    {
        return @"Please input your location.";
    }
    
    return [super errorMessageForInvalidInputs];
}

- (void)initContentWithPTask:(PTask *)task
{
    [super initContentWithPTask:task];
    
    self.txtCity.text = task.title;
    self.txtSubType.text = task.type3;
}

- (PTask *)inputData
{
    PTask *res = [super inputData];
    
    res.title = self.txtCity.text;
    res.type3 = self.txtSubType.text;
    
    return res;
}

- (void) resignAllTextInputs
{
    [super resignAllTextInputs];
    [self.txtCity resignFirstResponder];
    [self.txtSubType resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
