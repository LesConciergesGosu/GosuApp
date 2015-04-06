//
//  NewTaskGiftViewController.m
//  Gosu
//
//  Created by Dragon on 10/15/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "NewTaskGiftViewController.h"
#import "PTask.h"

@interface NewTaskGiftViewController ()

@end

@implementation NewTaskGiftViewController

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

#pragma mark Overridden methods

- (NSString *)errorMessageForInvalidInputs
{
    
    if ([self.txtPerson text].length == 0)
    {
        return @"Please input the name of person who you are shopping for.";
    }
    
    return [super errorMessageForInvalidInputs];
}

- (void)initContentWithPTask:(PTask *)task
{
    [super initContentWithPTask:task];
    
    self.txtPerson.text = task.title;
    self.txtLike.text = task.note2;
    self.txtDislike.text = task.note3;
    self.txtMind.text = task.note4;
}

- (PTask *)inputData
{
    PTask *res = [super inputData];
    
    res.title = self.txtPerson.text;
    res.note2 = self.txtLike.text;
    res.note3 = self.txtDislike.text;
    res.note4 = self.txtMind.text;
    
    return res;
}

- (void) resignAllTextInputs
{
    [super resignAllTextInputs];
    [self.txtPerson resignFirstResponder];
    [self.txtLike resignFirstResponder];
    [self.txtDislike resignFirstResponder];
    [self.txtMind resignFirstResponder];
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
