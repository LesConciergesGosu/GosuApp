//
//  NewTaskFoodViewController.m
//  Gosu
//
//  Created by Dragon on 10/14/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "NewTaskFoodViewController.h"
#import "DatePicker.h"
#import "NSDate+Task.h"
#import "NSDate+Extra.h"
#import "PTask.h"
#import "AppAppearance.h"

@interface NewTaskFoodViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>
{
    BOOL isASAP;
    NSInteger cuisineIndex;
}

@property (nonatomic, strong) NSArray *cuisines;
@end

@implementation NewTaskFoodViewController

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
    
    isASAP = NO;
    
    cuisineIndex = 0;
    NSArray *array = @[@"TAPAS",
                      @"FUSION",
                      @"HOMESTYLE",
                      @"ETHNIC"];
    
    cuisineIndex = [array indexOfObject:[self.subTaskType uppercaseString]];
    cuisineIndex = cuisineIndex == NSNotFound ? 0 : cuisineIndex + 1;
    [self.cuisineChooser selectRow:cuisineIndex inComponent:0 animated:NO];
    
    self.cuisines = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSString *)obj1 compare:(NSString *)obj2];
    }];
    
    [self.btnCuisine setTitle:[self.subTaskType uppercaseString] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Overridden methods

- (NSString *)errorMessageForInvalidInputs
{
    
    if ([self.txtTarget text].length == 0)
    {
        return @"Please input your location.";
    }
    
    if (self.startDate == nil && !isASAP)
        return @"Please pick the date and time.";
    
    return nil;
}

- (void)initContentWithPTask:(PTask *)task
{
    [super initContentWithPTask:task];
    
    self.txtTarget.text = task.title;
    
    isASAP = task.asap;
    if (isASAP) {
        self.startDate = task.date;
    }
    [self updateASAP];
    
    if (task.type2) {
        cuisineIndex = [self.cuisines indexOfObject:task.type2] + 1;
        [self.cuisineChooser selectRow:cuisineIndex inComponent:0 animated:NO];
    }
}

- (PTask *)inputData
{
    PTask *res = [super inputData];
    
    res.title = self.txtTarget.text;
    
    if (isASAP)
    {
        res.date = nil;
        res.asap = true;
    }
    else
    {
        res.date = self.startDate;
        res.asap = false;
    }
    
    if (cuisineIndex > 0 && cuisineIndex != NSNotFound)
        res.type2 = [self.cuisines[cuisineIndex - 1] lowercaseString];
    else
        res.type2 = nil;
    
    return res;
}

- (void) resignAllTextInputs
{
    [super resignAllTextInputs];
    [self.txtTarget resignFirstResponder];
}


#pragma mark Action
- (IBAction)onASAP:(id)sender
{
    isASAP = !isASAP;
    
    [self updateASAP];
}

- (void) updateASAP
{
    if (isASAP)
    {
        [self.btnStartDate setEnabled:NO];
        [self.btnStartDate setBackgroundColor:[AppAppearance darkTextColor]];
        [self.btnStartDate setAttributedTitle:nil forState:UIControlStateNormal];
        [self.btnStartDate setTitle:@"ASAP" forState:UIControlStateNormal];
        [self.btnStartDate setTintColor:[UIColor whiteColor]];
        [self.btnASAP setTitle:@"" forState:UIControlStateNormal];
        [self.btnASAP setImage:[UIImage imageNamed:@"asap_clock"] forState:UIControlStateNormal];
    }
    else
    {
        [self.btnStartDate setEnabled:YES];
        [self.btnStartDate setBackgroundColor:nil];
        [self.btnStartDate setTintColor:[AppAppearance darkTextColor]];
        if (self.startDate)
        {
            [self.btnStartDate setAttributedTitle:[self.startDate attributedDateTimeWithSize:15 forTaskType:self.taskType] forState:UIControlStateNormal];
            [self.btnStartDate setTitle:@"" forState:UIControlStateNormal];
        }
        else
        {
            [self.btnStartDate setAttributedTitle:nil forState:UIControlStateNormal];
            [self.btnStartDate setTitle:@"Pick Date & Time" forState:UIControlStateNormal];
        }
        [self.btnASAP setTitle:@"ASAP" forState:UIControlStateNormal];
        [self.btnASAP setImage:nil forState:UIControlStateNormal];
        
        self.datePicker.minimumDate = self.minimumDate ?: [NSDate date];
        
        if (self.maximumDate)
            self.datePicker.maximumDate = self.maximumDate;
        
        self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        self.datePicker.date = self.startDate ?: [self.datePicker.minimumDate dateInOneHour];
        self.datePicker.minuteInterval = 30;
        self.datePicker.tag = 2;
        
        UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
        [self.datePicker presentInView:window animated:YES completion:nil];
        [self.datePicker setValueChangedListener:self action:@selector(onASAPDatePicked:)];
    }
}

- (void) onASAPDatePicked:(DatePicker *)datePicker
{
    if (datePicker.tag == 2)
    {
        self.startDate = datePicker.date;
        [self.btnStartDate setAttributedTitle:[self.startDate attributedDateTimeWithSize:15 forTaskType:self.taskType] forState:UIControlStateNormal];
    }
}

- (IBAction)onChooseCuisine:(id)sender
{
    CGRect frame = self.cuisineChooserView.frame;
    frame.origin.y = CGRectGetMaxY(self.view.bounds);
    frame.size.width = self.view.bounds.size.width;
    self.cuisineChooserView.frame = frame;
    
    if (self.cuisineChooserView.superview != self.view)
        [self.view addSubview:self.cuisineChooserView];
    
    
    frame.origin.y = self.view.bounds.size.height - frame.size.height;
    [UIView animateWithDuration:0.25 animations:^{
        self.cuisineChooserView.frame = frame;
    }];
}

- (IBAction)onChooseCuisineDone:(id)sender
{
    CGRect frame = self.cuisineChooserView.frame;
    frame.origin.y = CGRectGetMaxY(self.view.bounds);
    [UIView animateWithDuration:0.25 animations:^{
        self.cuisineChooserView.frame = frame;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark Cuisine Picker
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.cuisines count] + 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (row == 0)
        return @"No restriction";
    
    return self.cuisines[row - 1];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    cuisineIndex = row;
    
    if (row == 0)
    {
        [self.btnCuisine setTitle:@"No restriction" forState:UIControlStateNormal];
    }
    else
    {
        [self.btnCuisine setTitle:self.cuisines[row - 1] forState:UIControlStateNormal];
    }
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
