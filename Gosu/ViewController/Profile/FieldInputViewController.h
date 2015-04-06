//
//  FieldInputViewController.h
//  Gosu
//
//  Created by dragon on 6/3/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FieldInputMethod) {
    FieldInputMethodText,
    FieldInputMethodPicker,
    FieldInputMethodDate
};

typedef NS_ENUM(NSInteger, FieldInputValueType) {
    FieldInputValueTypeInteger,
    FieldInputValueTypeFloat,
    FieldInputValueTypeString,
    FieldInputValueTypeDate
};

//
// title : 
// type : Integer / Float / String / Date
// default : default value (NSNumber or NSString or NSDate)
// method : TextField / Picker / Date Picker
// keyboard : 
// values : (used for Picker Mode)

@class FieldInputViewController;
@protocol FieldInputViewControllerDelgate <NSObject>
@optional
- (void)fieldInputViewController:(FieldInputViewController *)vc didFinishWithResults:(NSArray *)results;
- (void)fieldInputViewControllerDidCancel:(FieldInputViewController *)vc;

@end

@interface FieldInputViewController : UIViewController

@property (nonatomic, strong) NSArray *inputFields;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *container;
@property (nonatomic) NSInteger tag;

@property (weak) id<FieldInputViewControllerDelgate> delegate;

@end
