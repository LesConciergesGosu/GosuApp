//
//  NewTaskFlightViewController.m
//  Gosu
//
//  Created by Dragon on 10/12/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "NewTaskFlightViewController.h"
#import "PTask.h"
#import "NSDate+Task.h"
#import "NSDate+Extra.h"

@interface NewTaskFlightViewController ()

@end

@implementation NewTaskFlightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    NSDate *date = [(self.minimumDate ?: [NSDate date]) dateByAddingHours:1];
    NSTimeInterval interval = floor([date timeIntervalSince1970] / D_HOUR) * D_HOUR;
    date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    self.startDate = date;
    self.endDate = [date dateByAddingDays:1];
    
    if ([self.taskType isEqualToString:TASK_TYPE_FLIGHT])
    {
        self.txtAdults.inputAccessoryView = self.accessoryBar;
        self.txtChildren.inputAccessoryView = self.accessoryBar;
        self.txtInfants.inputAccessoryView = self.accessoryBar;
    }
    
    [self.btnStartDate setAttributedTitle:[self.startDate attributedDateTimeWithSize:15 forTaskType:self.taskType] forState:UIControlStateNormal];
    [self.btnEndDate setAttributedTitle:[self.endDate attributedDateTimeWithSize:15 forTaskType:self.taskType] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Actions


#pragma mark - Overriden methods

- (void)voiceRecognizer:(id)recognizer recognizedText:(NSString *)text
{
    self.txtTarget.text = text;
}

- (NSString *)errorMessageForInvalidInputs
{
    
    if ([self.txtTarget text].length == 0)
    {
        return @"Please input your destination.";
    }
    
    if ([self.startDate compare:[NSDate date]] <= 0)
    {
        return @"Depart date is past.";
    }
    
    if ([self.startDate compare:self.endDate] != NSOrderedAscending)
    {
        return @"Depart date is greater than the return date.";
    }
    
    if ([self.taskType isEqualToString:TASK_TYPE_FLIGHT] &&
        [[self.txtAdults text] integerValue] == 0)
    {
        return @"Please choose at least one adult.";
    }
    
    return [super errorMessageForInvalidInputs];
}

- (void)initContentWithPTask:(PTask *)task
{
    [super initContentWithPTask:task];
    
    self.txtTarget.text = task.title;
    
    if (task.date2) {
        self.endDate = task.date2;
        [self.btnEndDate setAttributedTitle:[self.endDate attributedDateTimeWithSize:15 forTaskType:self.taskType] forState:UIControlStateNormal];
    }
    
    if ([self.subTaskType isEqualToString:TASK_TYPE_FLIGHT])
    {
        self.txtAdults.text = [NSString stringWithFormat:@"%d", task.numberOfAdults];
        self.txtChildren.text = [NSString stringWithFormat:@"%d", task.numberOfChildren];
        self.txtInfants.text = [NSString stringWithFormat:@"%d", task.numberOfInfants];
    }
    else if ([self.taskType isEqualToString:TASK_TYPE_ACCOMODATION])
    {
        
    }
}

- (PTask *)inputData
{
    PTask *res = [super inputData];
    
    res.title = self.txtTarget.text;
    res.date2 = self.endDate;
    
    if ([self.subTaskType isEqualToString:TASK_TYPE_FLIGHT])
    {
        res.numberOfAdults = [[self.txtAdults text] intValue];
        res.numberOfChildren = [[self.txtChildren text] intValue];
        res.numberOfInfants = [[self.txtInfants text] intValue];
        res.desc = [NSString stringWithFormat:@"Book a flight to %@", res.title];
    }
    else if ([self.taskType isEqualToString:TASK_TYPE_ACCOMODATION])
    {
        res.desc = [NSString stringWithFormat:@"Book a accomodation in %@", res.title];
    }
    
    return res;
}

- (void) resignAllTextInputs
{
    [super resignAllTextInputs];
    [self.txtTarget resignFirstResponder];
    
    if ([self.taskType isEqualToString:TASK_TYPE_FLIGHT])
    {
        [self.txtAdults resignFirstResponder];
        [self.txtChildren resignFirstResponder];
        [self.txtInfants resignFirstResponder];
    }
}
@end
