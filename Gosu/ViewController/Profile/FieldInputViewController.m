//
//  FieldInputViewController.m
//  Gosu
//
//  Created by dragon on 6/3/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "FieldInputViewController.h"
#import "BaseInputFieldCell.h"

@interface FieldInputViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) NSArray *results;
@property (nonatomic, strong) NSArray *controls;
@end

@implementation FieldInputViewController

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
    
    // initialize the data source
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSDictionary *field in self.inputFields) {
        NSMutableDictionary *res = [@{@"value": field[@"default"]} mutableCopy];
        [array addObject:res];
    }
    
    self.results = array;
    
    // setup the input controls
    [self setupControls];
    
    // setup the navigation items.
    if ([self.navigationController.viewControllers indexOfObject:self] == 0) {
        
        // view controller is being presented.
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancel:)];
        
    } else {
        
        // view controller is being pushed.
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone:)];
    
}

- (void)onDone:(id)sender
{
    for (int i = 0; i < [self.inputFields count]; i ++) {
        
        NSDictionary *field = self.inputFields[i];
        FieldInputMethod method = [field[@"method"] intValue];
        if (method == FieldInputMethodText) {
            UITextField *textField = (UITextField *)self.controls[i];
            
            NSMutableDictionary *res = self.results[i];
            res[@"value"] = textField.text;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(fieldInputViewController:didFinishWithResults:)]) {
        [self.delegate fieldInputViewController:self didFinishWithResults:self.results];
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
    if ([self.delegate respondsToSelector:@selector(fieldInputViewControllerDidCancel:)]) {
        [self.delegate fieldInputViewControllerDidCancel:self];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setupControls
{
    
    CGFloat baseY = 0;
    
    NSMutableArray *controls = [NSMutableArray array];
    
    for (int i = 0; i < [self.inputFields count]; i ++) {
        
        NSDictionary *inputField = self.inputFields[i];
        
        
        //
        // Header
        //
        CGRect headerFrame = CGRectMake(10, baseY + 20, 300, 30);
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:headerFrame];
        headerLabel.text = inputField[@"title"];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.textColor = APP_COLOR_GREEN;
        
        [self.container addSubview:headerLabel];
        
        baseY = CGRectGetMaxY(headerFrame);
        
        //
        // Output
        //
        
        
        UIView *control = [self controlForInputField:inputField withTag:i];
        CGRect controlFrame = control.frame;
        controlFrame.origin.y = baseY + 10;
        control.frame = controlFrame;
        [self.container addSubview:control];
        
        [controls addObject:control];
        
        baseY = CGRectGetMaxY(controlFrame);
        
    }
    
    self.controls = controls;
    self.container.frame = CGRectMake(0, 0, 320, baseY + 20);
    self.scrollView.contentSize = self.container.frame.size;
}

- (UIView *)controlForInputField:(NSDictionary *)info withTag:(int)tag {
    
    FieldInputMethod inputMethod = [info[@"method"] intValue];
    
    UIView *res = nil;
    
    if (inputMethod == FieldInputMethodText) {
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, 300, 30)];
        textField.text = [NSString stringWithFormat:@"%@", info[@"default"]];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.tag = tag;
        
        if (info[@"keyboard"]) {
            
            textField.keyboardType = [info[@"keyboard"] intValue];
            
        } else {
            
            FieldInputValueType type = [info[@"type"] intValue];
            
            switch (type) {
                case FieldInputValueTypeFloat:
                case FieldInputValueTypeInteger:
                    textField.keyboardType = UIKeyboardTypeDecimalPad;
                    break;
                case FieldInputValueTypeString:
                    textField.keyboardType = UIKeyboardTypeDefault;
                    break;
                    
                default:
                    break;
            }
        }
        
        res = textField;
        
    } else if (inputMethod == FieldInputMethodPicker) {
        
        UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 0, 300, 100)];
        pickerView.tag = tag;
        pickerView.dataSource = self;
        pickerView.delegate = self;
        res = pickerView;
        
        NSString *def;
        if (( def = info[@"default"] )) {
            NSArray *values = info[@"values"];
            NSUInteger index = [values indexOfObject:def];
            if (index != NSNotFound) {
                [pickerView selectRow:index inComponent:0 animated:NO];
            }
        }
        
    } else if (inputMethod == FieldInputMethodDate) {
        UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(10, 0, 300, 80)];
        datePicker.tag = tag;
        datePicker.datePickerMode = UIDatePickerModeDate;
        datePicker.date = info[@"default"];
        [datePicker addTarget:self action:@selector(onDateUpdated:) forControlEvents:UIControlEventValueChanged];
    }
    
    return res;
}

- (void)onDateUpdated:(UIDatePicker *)sender
{
    NSInteger index = sender.tag;
    NSMutableDictionary *res = self.results[index];
    res[@"value"] = sender.date;
}

#pragma mark UIPicker View Delegate & DataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    NSInteger index = pickerView.tag;
    NSDictionary *inputField = self.inputFields[index];
    
    return [inputField[@"values"] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSInteger index = pickerView.tag;
    NSDictionary *inputField = self.inputFields[index];
    NSArray *values = inputField[@"values"];
    
    return values[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSInteger index = pickerView.tag;
    NSDictionary *inputField = self.inputFields[index];
    NSArray *values = inputField[@"values"];
    
    NSString *value = values[row];
    
    NSMutableDictionary *res = self.results[index];
    res[@"value"] = value;
    
}

@end
