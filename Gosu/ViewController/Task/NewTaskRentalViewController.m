//
//  NewTaskRentalViewController.m
//  Gosu
//
//  Created by Dragon on 10/15/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "NewTaskRentalViewController.h"
#import "PTask.h"
#import <Parse/Parse.h>

@interface NewTaskRentalViewController ()

@end

@implementation NewTaskRentalViewController

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
    
    if (self.startLocation.latitude == 0 && self.startLocation.longitude == 0)
        return @"Please input pick up location.";
    
    if (self.btnStartDate && !self.startDate)
        return @"Please input pick up date & time.";
    
    if (self.btnEndDate && !self.endDate)
        return @"Please input pick up date & time.";
    
    return [super errorMessageForInvalidInputs];
}

- (void)initContentWithPTask:(PTask *)task
{
    [super initContentWithPTask:task];
    
    self.txtVehicleType.text = task.type3;
    if (task.location)
        self.startLocation = CLLocationCoordinate2DMake(task.location.latitude, task.location.longitude);
}

- (PTask *)inputData
{
    PTask *res = [super inputData];
    
    res.location = [PFGeoPoint geoPointWithLatitude:self.startLocation.latitude longitude:self.startLocation.longitude];
    res.type3 = self.txtVehicleType.text;
    
    return res;
}

- (void) resignAllTextInputs
{
    [super resignAllTextInputs];
    [self.txtVehicleType resignFirstResponder];
}


@end
