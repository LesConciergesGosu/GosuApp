//
//  GeneralInfomationAddViewController.h
//  Gosu
//
//  Created by dragon on 6/5/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GeneralInfomationAddViewController;
@protocol GeneralInfomationAddViewControllerDelegate <NSObject>
@optional
- (void)generalInformationAddViewController:(GeneralInfomationAddViewController *)vc didFinishWithResult:(NSDictionary *)result;
- (void)generalInformationAddViewControllerDidCancel:(GeneralInfomationAddViewController *)vc;
@end

@interface GeneralInfomationAddViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic) id<GeneralInfomationAddViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *availableTypes;

// reserved, actually not used
@property (nonatomic) int tag;
// reserved, actually not used
@property (nonatomic, strong) id data;

+ (NSArray *)availableInformationTypes;
@end
