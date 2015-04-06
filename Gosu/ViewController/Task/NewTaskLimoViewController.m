//
//  NewTaskLimoViewController.m
//  Gosu
//
//  Created by Dragon on 10/14/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "NewTaskLimoViewController.h"
#import "PTask.h"
#import <Parse/Parse.h>

@interface NewTaskLimoViewController ()

@end

@implementation NewTaskLimoViewController

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
    
    self.startLocation = CLLocationCoordinate2DMake(0, 0);
    self.endLocation = CLLocationCoordinate2DMake(0, 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTypeChanged:(id)sender
{
    CGRect frame = self.contentView.frame;
    CGFloat locationAlpha = 0;
    CGFloat hoursAlpha = 0;
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        locationAlpha = 1;
        hoursAlpha = 0;
        frame.size.height = CGRectGetMaxY(self.viewLocation.frame) + CGRectGetHeight(self.viewOthers.frame) + 1;
    }
    else
    {
        locationAlpha = 0;
        hoursAlpha = 1;
        frame.size.height = CGRectGetMaxY(self.viewHours.frame) + CGRectGetHeight(self.viewOthers.frame) + 1;
    }
    
    [UIView animateWithDuration:.2 animations:^{
        self.viewLocation.alpha = locationAlpha;
        self.viewHours.alpha = hoursAlpha;
        self.contentView.frame = frame;
    } completion:^(BOOL finished) {
        self.scrollView.contentSize = frame.size;
    }];
}

#pragma mark Overridden methods

- (NSString *)errorMessageForInvalidInputs
{
    
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        if (self.startLocation.latitude == 0 && self.startLocation.longitude == 0)
            return @"Please input pick up location.";
        else if (self.endLocation.latitude == 0 && self.endLocation.longitude == 0)
            return @"Please input drop off location.";
    }
    else
    {
        if ([self.txtHours.text intValue] <= 0)
        {
            return @"Please input hours.";
        }
    }
    
    return [super errorMessageForInvalidInputs];
}

- (void)initContentWithPTask:(PTask *)task
{
    [super initContentWithPTask:task];
    
    if ([task.type3 isEqualToString:TASK_TYPE_LIMO_DESTINATION]) {
        self.segmentedControl.selectedSegmentIndex = 0;
        self.txtHours.text = [NSString stringWithFormat:@"%d", task.hours];
    } else {
        self.segmentedControl.selectedSegmentIndex = 1;
        
        if (task.location)
            self.startLocation = CLLocationCoordinate2DMake(task.location.latitude, task.location.longitude);
        
        if (task.location2)
            self.endLocation = CLLocationCoordinate2DMake(task.location2.latitude, task.location2.longitude);
    }
}

- (PTask *)inputData
{
    PTask *res = [super inputData];
    
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        res.hours = [self.txtHours.text intValue];
        res.type3 = TASK_TYPE_LIMO_DESTINATION;
    }
    else
    {
        res.location = [PFGeoPoint geoPointWithLatitude:self.startLocation.latitude longitude:self.startLocation.longitude];
        res.location2 = [PFGeoPoint geoPointWithLatitude:self.endLocation.latitude longitude:self.endLocation.longitude];
        res.type3 = TASK_TYPE_LIMO_HOURLY;
    }
    
    return res;
}

- (void) resignAllTextInputs
{
    [super resignAllTextInputs];
    [self.txtHours resignFirstResponder];
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
