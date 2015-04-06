//
//  DatePicker.h
//  Gosu
//
//  Created by Dragon on 10/13/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatePicker : UIView

@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;

@property (nonatomic) UIDatePickerMode datePickerMode;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, copy) NSDate *minimumDate;
@property (nonatomic, copy) NSDate *maximumDate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic) NSTimeInterval minuteInterval;
@property (nonatomic) BOOL sendChangedEventOnDone;
@property (nonatomic) BOOL continueous;

@property (nonatomic, strong) ObjectBlock doneBlock;
@property (nonatomic, strong) ObjectBlock cancelBlock;

+(instancetype)datePicker;
- (void)presentInView:(UIView *)view animated:(BOOL)animated completion:(void (^)())completion;
- (void)dismissAnimated:(BOOL)animated completion:(void (^)())completion;
- (void)setValueChangedListener:(id)listener action:(SEL)action;
@end
