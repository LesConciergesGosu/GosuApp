//
//  ConfirmExperienceViewController.m
//  Gosu
//
//  Created by Dragon on 12/6/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "ConfirmExperienceViewController.h"
#import "EditExperienceViewController.h"
#import "Experience+Extra.h"
#import "Task+Extra.h"
#import "ExperienceTaskTableCell.h"
#import "DatePicker.h"
#import "TaskTimeWarningView.h"

#import <SVProgressHUD/SVProgressHUD.h>


@interface ConfirmExperienceViewController ()<UITableViewDataSource, UITableViewDelegate, ExperienceTaskTableCellDelegate>
{
    CGFloat screenWidth;
}

@property (nonatomic, strong) NSMutableArray *tasks;
@property (nonatomic, strong) NSMutableArray *recommendations;
@property (nonatomic, weak) id selectedItem;

@property (nonatomic, strong) NSDateFormatter *taskDateFormatter;
@property (nonatomic, strong) DatePicker *datePicker;

@end

@implementation ConfirmExperienceViewController
@synthesize datePicker = _datePicker;

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
    
    self.title = @"MOVIE WITH SUSIE";
    
    self.selectedItem = nil;
    
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onEdit:)];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mma"];
    self.taskDateFormatter = dateFormatter;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onExperienceUpdated:)
                                                 name:NotificationExperienceUpdated
                                               object:nil];
    
    [self reloadLocalData];
    [self buildRecommendations];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self checkIfAllFilled];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Privates

- (void)buildRecommendations
{
    for (Task *task in self.experience.tasks)
    {
        if ([task.type isEqualToString:TASK_TYPE_FOOD])
        {
            task.recommendations = @[@{@"title":@"Angelo’s Diner",
                                       @"desc":@"Italian",
                                       @"times":@[@"7:00", @"7:15", @"7:30"]
                                       },
                                     @{@"title":@"The Gold Mirror",
                                       @"desc":@"Italian Fusion",
                                       @"times":@[@"7:00", @"7:15", @"7:30"]
                                       }];
        }
        else if ([task.type isEqualToString:TASK_TYPE_MOVIE])
        {
            task.recommendations = @[@{@"title":@"Fury",
                                       @"desc":@"1h 57m",
                                       @"times":@[@"8:15", @"8:45", @"9:10"]}];
        }
    }
}


- (void)reloadLocalData
{
    self.tasks = [[self.experience.tasks array] mutableCopy];
    self.selectedItem = nil;
    [self.tableView reloadData];
}

- (void)checkIfAllFilled
{
    BOOL filled = YES;
    
    for (Task *task in self.tasks) {
        
        if (!task.date) {
            filled = NO;
            break;
        }
    }
    
    if (filled) {
        
        UIEdgeInsets inset = self.tableView.contentInset;
        inset.bottom = self.confirmButtonView.bounds.size.height;
        [UIView animateWithDuration:.2 animations:^{
            self.confirmButtonView.alpha = 1;
            self.tableView.contentInset = inset;
        }];
    }
}

#pragma mark Editing
- (void) onEdit:(id)sender
{
    [self performSegueWithIdentifier:@"Edit" sender:nil];
}

#pragma mark Date Picker

- (void)validateDateAtIndex:(NSInteger)index completion:(void (^)(void))completion
{
    if (index >= [self.tasks count] - 1) {
        completion();
        return;
    }
    
    Task *task = self.tasks[index];
    Task *nextTask = self.tasks[index + 1];
    
    if ([task.date compare:nextTask.date] == NSOrderedAscending) {
        
        [self validateDateAtIndex:index + 1 completion:completion];
        
    } else {
        
        TaskTimeWarningView *warningView = [TaskTimeWarningView taskTimeWarningViewWithParent:self.navigationController.view];
        
        warningView.detailView.backgroundColor = [Task colorForType:task.type];
        warningView.imvIcon.image = [Task iconForType:task.type subType:task.type2];
        warningView.lblTaskType.text = [Task shortTitleForType:task.type subType:task.type2];
        warningView.lblTime.text = [self.taskDateFormatter stringFromDate:task.date];
        warningView.lblDescription.text = [NSString stringWithFormat:@"You might be late\nto your %@", [[Task shortTitleForType:nextTask.type subType:nextTask.type2] lowercaseString]];
        
        __weak ConfirmExperienceViewController *wself = self;
        [warningView setDoneBlock:^(id object) {
            
            __strong ConfirmExperienceViewController *sself = wself;
            
            if (!sself)
                return;
            
            [sself validateDateAtIndex:index + 1 completion:completion];
            
        }];
        
        [warningView setCancelBlock:^(id object) {
            
        }];
        
        [warningView show];
        
        return;
    }
}

- (BOOL)checkIfDate:(NSDate *)date validForTask:(Task *)task
{
    NSInteger index = [self.tasks indexOfObject:task];
    
    if (index >= [self.tasks count] - 1)
        return YES;
    
    Task *nextTask = self.tasks[index + 1];
    
    if (!nextTask.date || [date compare:nextTask.date] == NSOrderedAscending)
        return YES;
    
    TaskTimeWarningView *warningView = [TaskTimeWarningView taskTimeWarningViewWithParent:self.navigationController.view];
    
    warningView.detailView.backgroundColor = [Task colorForType:task.type];
    warningView.imvIcon.image = [Task iconForType:task.type subType:task.type2];
    warningView.lblTaskType.text = [Task shortTitleForType:task.type subType:task.type2];
    warningView.lblTime.text = [self.taskDateFormatter stringFromDate:date];
    warningView.lblDescription.text = [NSString stringWithFormat:@"You might be late\nto your %@", [[Task shortTitleForType:nextTask.type subType:nextTask.type2] lowercaseString]];
    
    __weak ConfirmExperienceViewController *wself = self;
    [warningView setDoneBlock:^(id object) {
        
        __strong ConfirmExperienceViewController *sself = wself;
        
        if (sself && [sself.tasks indexOfObject:task] != NSNotFound)
        {
            task.date = date;
            task.changed = YES;
            [sself.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[sself.tasks indexOfObject:task] inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    }];
    
    [warningView setCancelBlock:^(id object) {
        
    }];
    
    [warningView show];
    
    return NO;
}

- (DatePicker *)datePicker
{
    if (!_datePicker)
    {
        _datePicker = [DatePicker datePicker];
        
        __weak ConfirmExperienceViewController *wself = self;
        [_datePicker setCancelBlock:^(id datePicker) {
            
            __strong ConfirmExperienceViewController *sself = wself;
            
            if (sself && sself.selectedItem)
            {
                NSInteger originalIndex = [sself.tasks indexOfObject:sself.selectedItem];
                
                sself.selectedItem = nil;
                
                if (originalIndex != NSNotFound)
                {
                    [sself.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:originalIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                }
            }
        }];
        
        [_datePicker setDoneBlock:^(DatePicker *datePicker) {
            
            __strong ConfirmExperienceViewController *sself = wself;
            
            if (sself.selectedItem)
            {
                Task *task = sself.selectedItem;
                
                if ([sself checkIfDate:datePicker.date validForTask:task])
                {
                    task.date = sself.datePicker.date;
                    task.changed = YES;
                    
                    [sself checkIfAllFilled];
                }
                
                NSInteger originalIndex = [sself.tasks indexOfObject:sself.selectedItem];
                
                sself.selectedItem = nil;
                
                if (originalIndex != NSNotFound)
                {
                    [sself.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:originalIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                }
            }
            
        }];
        
    }
    
    return _datePicker;
}

- (void)showDatePickerWithDate:(NSDate *)date
{
    self.datePicker.date = date;
    
    UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
    [self.datePicker presentInView:window animated:YES completion:nil];
}



#pragma mark Action
- (IBAction)onConfirm:(id)sender
{
    __weak ConfirmExperienceViewController *wself = self;
    [self validateDateAtIndex:0 completion:^{
        
        __strong ConfirmExperienceViewController *sself = wself;
        
        [sself onValidateCompleted];
        
    }];
}

- (void)onValidateCompleted
{
    NSMutableArray *array = [NSMutableArray array];
    for (Task *task in self.tasks) {
        [array addObject:[task PFObject]];
    }
    
    [SVProgressHUD show];
    
    __weak ConfirmExperienceViewController *wself = self;
    [Experience confirmExperienceWithId:self.experience.objectId WithPFTasks:array completion:^(BOOL success, id pfObject, NSString *errorDesc) {
        
        __strong ConfirmExperienceViewController *sself = wself;
        
        if (success) {
            [SVProgressHUD dismiss];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationExperienceUpdated object:sself.experience];
            [sself.navigationController popViewControllerAnimated:YES];
            
        } else {
            [SVProgressHUD showErrorWithStatus:@"Failed"];
        }
        
    }];
}

#pragma mark Task Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tasks count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Task *task = self.tasks[indexPath.row];
    if (self.selectedItem == self.tasks[indexPath.row] &&
        ([task.type isEqualToString:TASK_TYPE_FOOD] ||
         [task.type isEqualToString:TASK_TYPE_ENTERTAINMENT]))
        
        return screenWidth * 0.5 + 76;
    
    return 51;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *res = nil;
    
    Task *task = self.tasks[indexPath.row];
    UIColor *typeColor = [Task colorForType:task.type];
    
    if (self.selectedItem == task)
    {
        
        if ([task.type isEqualToString:TASK_TYPE_FOOD] ||
            [task.type isEqualToString:TASK_TYPE_ENTERTAINMENT])
        {
            ExperienceTaskTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskCellSelected2"];
            for (UIView *colorView in cell.colorViews)
                colorView.backgroundColor = typeColor;
            cell.lblTitle.text = [Task shortTitleForType:task.type subType:task.type2];
            cell.imvType.image = [Task iconForType:task.type subType:task.type2];
            cell.delegate = self;
            cell.data = task;
            
            [cell.cltRecommendations reloadData];
            
            res = cell;
        }
        else
        {
            ExperienceTaskTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskCellSelected"];
            for (UIView *colorView in cell.colorViews)
                colorView.backgroundColor = typeColor;
            cell.lblTitle.text = [Task shortTitleForType:task.type subType:task.type2];
            cell.imvType.image = [Task iconForType:task.type subType:task.type2];
            cell.delegate = self;
            
            if (task.date)
                [cell.lblDesc setText:[self.taskDateFormatter stringFromDate:task.date]];
            else
                [cell.lblDesc setText:@"--:--"];
            
            res = cell;
        }
    }
    else
    {
        ExperienceTaskTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskCellNormal"];
        
        for (UIView *colorView in cell.colorViews)
            colorView.backgroundColor = typeColor;
        cell.lblTitle.text = [Task shortTitleForType:task.type subType:task.type2];
        cell.imvType.image = [Task iconForType:task.type subType:task.type2];
        cell.delegate = self;
        
        if (task.date)
            [cell.lblDesc setText:[self.taskDateFormatter stringFromDate:task.date]];
        else
            [cell.lblDesc setText:@"--:--"];
        
        res = cell;
    }
    
    return res;
}

- (void)experienceTaskTableCell:(id)cell tappedButtonAtIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Task *task = self.tasks[indexPath.row];
    
    if(task == self.selectedItem)
    {
        self.selectedItem = nil;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        
        NSInteger originalIndex = self.selectedItem ? [self.tasks indexOfObject:self.selectedItem] : NSNotFound;
        
        self.selectedItem = task;
        if (originalIndex != NSNotFound)
        {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:originalIndex inSection:0], indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        
        if ([task.type isEqualToString:TASK_TYPE_FOOD] ||
            [task.type isEqualToString:TASK_TYPE_ENTERTAINMENT])
        {
        }
        else
        {
            [self showDatePickerWithDate:task.date];
        }
    }
    
}


#pragma mark Recommendation Collection View

- (NSInteger)numberOfRecommendationsForExperienceTaskTableCell:(id)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Task *task = self.tasks[indexPath.row];
    
    return [task.recommendations count] + 1;
}

- (UICollectionViewCell *)experienceTaskTableCell:(id)cell collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger index = [self.tableView indexPathForCell:cell].row;
    Task *task = self.tasks[index];
    
    NSArray *recommendations = task.recommendations;
    
    if (indexPath.row >= [recommendations count])
    {
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"NoteCell" forIndexPath:indexPath];
    }
    
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"RecommendationCell" forIndexPath:indexPath];
}

#pragma mark Edit Experience

- (void)onExperienceUpdated:(NSNotification *)notification
{
    if (self.experience == notification.object) {
        [self reloadLocalData];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[EditExperienceViewController class]])
    {
        EditExperienceViewController *vc = (EditExperienceViewController *)segue.destinationViewController;
        vc.experience = self.experience;
    }
}

@end
