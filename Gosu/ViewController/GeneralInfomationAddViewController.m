//
//  GeneralInfomationAddViewController.m
//  Gosu
//
//  Created by dragon on 6/5/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "GeneralInfomationAddViewController.h"
#import "TextInputFieldCell.h"
#import "PickerInputFieldCell.h"
#import "DateInputFieldCell.h"
#import "TableHeaderView.h"
#import "TableFooterView.h"

@interface GeneralInfomationAddViewController ()<UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, BaseInputFieldCellDelegate>
{
    PersonalInfoType curInfoType;
}
@property (nonatomic, strong) NSMutableDictionary *result;
@end

@implementation GeneralInfomationAddViewController

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
    
    // setup section header/footer for the tableview
    [self.tableView registerNib:[UINib nibWithNibName:@"TableHeaderView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"profileSectionHeader"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TableFooterView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"profileSectionFooter"];
    
    // initialize data source
    
    if (!self.availableTypes)
        self.availableTypes = @[@(PersonalInfoTypeAddress), @(PersonalInfoTypeBirthday), @(PersonalInfoTypePassport)];
    
    self.availableTypes = [self.availableTypes arrayByAddingObject:@(PersonalInfoTypeOther)];
    
    curInfoType = [self.availableTypes[0] intValue];
    self.result = [NSMutableDictionary dictionary];
    
    
    // setup navigation items
    
    if ([self.navigationController.viewControllers indexOfObject:self] == 0) {
        
        // view controller is being presented.
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancel:)];
        
    } else {
        
        // view controller is being pushed.
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone:)];
}

+ (NSArray *)availableInformationTypes
{
    return @[@(PersonalInfoTypeAddress), @(PersonalInfoTypeBirthday), @(PersonalInfoTypePassport)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Privates
- (void)onDone:(id)sender
{
    
    [self.view endEditing:YES];
    
    NSDictionary *result = nil;
    NSError *error = nil;
    
    if (![self retrieveResult:&result withError:&error]) {
        
        [[[UIAlertView alloc] initWithTitle:[error displayString]
                                    message:nil
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
    
    
    if ([self.delegate respondsToSelector:@selector(generalInformationAddViewController:didFinishWithResult:)]) {
        [self.delegate generalInformationAddViewController:self didFinishWithResult:result];
    } else if (self.navigationController) {
        if ([self.navigationController.viewControllers indexOfObject:self] == 0) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)onCancel:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(generalInformationAddViewControllerDidCancel:)]) {
        [self.delegate generalInformationAddViewControllerDidCancel:self];
    } else if (self.navigationController) {
        if ([self.navigationController.viewControllers indexOfObject:self] == 0) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (BOOL)retrieveResult:(NSDictionary **)result withError:(NSError **)error
{
    switch (curInfoType) {
            
        case PersonalInfoTypeAddress:
            
            if ([self.result[@"address"] length] == 0) {
                *error = [NSError appErrorWithMessage:@"The address is empty."];
                return NO;
            }
            
            *result = @{@"type":@(PersonalInfoTypeAddress),
                        @"title":@"Address",
                        @"value":self.result[@"address"]};
            break;
            
        case PersonalInfoTypeBirthday:
            *result = @{@"type":@(PersonalInfoTypeBirthday),
                        @"title":@"Birthday",
                        @"value":self.result[@"birthday"] ? self.result[@"birthday"] : [NSDate date]};
                        
            break;
            
        case PersonalInfoTypePassport:
            if ([self.result[@"passport_number"] length] == 0) {
                *error = [NSError appErrorWithMessage:@"The passport number is empty."];
                return NO;
            }
            *result = @{@"type":@(PersonalInfoTypePassport),
                        @"title":@"Passport",
                        @"value":@{@"number":self.result[@"passport_number"],
                                   @"expireDate":self.result[@"passport_expire"] ? self.result[@"passport_expire"] : [NSDate date]}};
            break;
            
        case PersonalInfoTypeOther:
            if ([self.result[@"subject"] length] == 0) {
                *error = [NSError appErrorWithMessage:@"The subject is empty."];
                return NO;
            }
            
            if ([self.result[@"value"] length] == 0) {
                *error = [NSError appErrorWithMessage:@"The content is empty."];
                return NO;
            }
            
            *result = @{@"type":@(PersonalInfoTypeBirthday),
                        @"title":self.result[@"subject"],
                        @"value":self.result[@"value"]};
            break;
            
        default:
            break;
    }
    
    
    
    return YES;
}

#pragma mark Picker View

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.availableTypes count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    NSString *res = @"";
    
    switch ([self.availableTypes[row] intValue]) {
            
        case PersonalInfoTypeAddress:
            res = @"Address";
            break;
            
        case PersonalInfoTypeBirthday:
            res = @"Birthday";
            break;
            
        case PersonalInfoTypePassport:
            res = @"Passport";
            break;
        
        case PersonalInfoTypeOther:
            res = @"Other";
            break;
            
        default:
            break;
    }
    
    return res;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    [self.result removeAllObjects];
    
    curInfoType = [self.availableTypes[row] intValue];
    [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    NSInteger res = 0;
    
    switch (curInfoType) {
            
        case PersonalInfoTypeAddress:
            res = 1; // Address
            break;
            
        case PersonalInfoTypeBirthday:
            res = 1; // Date
            break;
            
        case PersonalInfoTypePassport:
            res = 2; // Passport Number & Expire Date
            break;
            
        case PersonalInfoTypeOther:
            res = 2; // Subject & Value
            break;
            
        default:
            break;
    }
    
    return res;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

#pragma mark Header/Footer

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    TableHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"profileSectionHeader"];
    
    
    if (!headerView.backgroundView) {
        headerView.backgroundView = [[UIView alloc] initWithFrame:headerView.bounds];
        headerView.backgroundView.backgroundColor = APP_COLOR_BACKGROUND;
    }
    
    switch (curInfoType) {
            
        case PersonalInfoTypeAddress:
            
            headerView.titleLabel.text = @"Address :";
            break;
            
        case PersonalInfoTypeBirthday:
            
            headerView.titleLabel.text = @"Birthday :";
            break;
            
        case PersonalInfoTypePassport:
            
            if (section == 0)
                headerView.titleLabel.text = @"Passport Number :";
            else
                headerView.titleLabel.text= @"Expires on :";
            break;
            
        case PersonalInfoTypeOther:
            
            if (section == 0)
                headerView.titleLabel.text = @"Subject :";
            else
                headerView.titleLabel.text= @"Content :";
            break;
            
        default:
            break;
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    TableFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"profileSectionFooter"];
    
    if (!footerView.backgroundView) {
        footerView.backgroundView = [[UIView alloc] initWithFrame:footerView.bounds];
        footerView.backgroundView.backgroundColor = APP_COLOR_BACKGROUND;
    }
    
    return footerView;
}

#pragma mark Cell

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat res = 0;
    
    switch (curInfoType) {
            
        case PersonalInfoTypeAddress:
            res = 44;
            break;
            
        case PersonalInfoTypeBirthday:
            res = 170;
            break;
            
        case PersonalInfoTypePassport:
            if (indexPath.section == 0)
                res = 44; // Passport Number
            else
                res= 170; // Expire Date
            break;
            
        case PersonalInfoTypeOther:
            res = 44;
            break;
        default:
            break;
    }
    
    
    return res;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *res = nil;
    
    switch (curInfoType) {
            
        case PersonalInfoTypeAddress:
        {
            TextInputFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextInputFieldCell"];
            cell.textField.text = self.result[@"address"] ? self.result[@"address"] : @"";
            cell.delegate = self;
            cell.indexPath = indexPath;
            
            res = cell;
            res.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
            
        case PersonalInfoTypeBirthday:
        {
            DateInputFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DateInputFieldCell"];
            cell.delegate = self;
            cell.datePicker.minimumDate = nil;
            cell.datePicker.maximumDate = [NSDate date];
            if (self.result[@"birthday"])
                cell.datePicker.date = self.result[@"birthday"] ? self.result[@"birthday"] : [NSDate date];
            cell.indexPath = indexPath;
            
            res = cell;
            res.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
            
        case PersonalInfoTypePassport:
        {
            if (indexPath.section == 0) {
                
                TextInputFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextInputFieldCell"];
                cell.textField.text = self.result[@"passport_number"] ? self.result[@"passport_number"] : @"";
                cell.delegate = self;
                cell.indexPath = indexPath;
                
                res = cell;
                
            } else {
                
                DateInputFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DateInputFieldCell"];
                cell.delegate = self;
                cell.datePicker.minimumDate = nil;
                cell.datePicker.maximumDate = nil;
                cell.datePicker.date = self.result[@"passport_expire"] ? self.result[@"passport_expire"] : [NSDate date];
                cell.indexPath = indexPath;
                
                res = cell;
            }
            res.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
            break;
            
        case PersonalInfoTypeOther:
        {
            
            TextInputFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextInputFieldCell"];
            cell.delegate = self;
            cell.indexPath = indexPath;
            
            res = cell;
            
            if (indexPath.section == 0) {
                
                cell.textField.text = self.result[@"subject"] ? self.result[@"subject"] : @"";
                
            } else {
                
                cell.textField.text = self.result[@"value"] ? self.result[@"value"] : @"";
            }
            res.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
            
        default:
            break;
    }
    
    return res;
}

- (void)baseInputFieldCell:(BaseInputFieldCell *)cell valueChanged:(id)newValue
{
    NSIndexPath *indexPath = cell.indexPath;
    
    switch (curInfoType) {
            
        case PersonalInfoTypeAddress:
        {
            self.result[@"address"] = newValue;
        }
            break;
            
        case PersonalInfoTypeBirthday:
        {
            self.result[@"birthday"] = newValue;
        }
            break;
            
        case PersonalInfoTypePassport:
        {
            if (indexPath.section == 0) {
                
                self.result[@"passport_number"] = newValue;
                
            } else {
                
                self.result[@"passport_expire"] = newValue;
            }
            
        }
            
        case PersonalInfoTypeOther:
        {
            if (indexPath.section == 0) {
                self.result[@"subject"] = newValue;
            } else {
                self.result[@"value"] = newValue;
            }
        }
            
        default:
            break;
    }
}


@end
