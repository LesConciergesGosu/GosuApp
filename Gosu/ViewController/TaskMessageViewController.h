//
//  TaskMessageViewController.h
//  Gosu
//
//  Created by dragon on 3/23/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioManager.h"

@class DotSpinView;
@class Task;
@interface TaskMessageViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate>

@property (strong) Task *task;

/// title label, not contained in contentView
@property (nonatomic, weak) IBOutlet UILabel *roomTitleLabel;

/// contains tableView & accessoryView
@property (nonatomic, weak) IBOutlet UIView *contentView;

/// chatting history table view
@property (nonatomic, weak) IBOutlet UITableView *tableView;

/// contains text field & left/right buttons(camera, voice)
@property (nonatomic, weak) IBOutlet UIView *accessoryView;

/// text field
@property (nonatomic, weak) IBOutlet UITextField *txtMessage;

@property (nonatomic, weak) IBOutlet DotSpinView *voiceRecordingIndicator;

- (void) reloadData;
@end
