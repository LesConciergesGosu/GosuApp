//
//  DatePicker.m
//  Gosu
//
//  Created by Dragon on 10/13/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "DatePicker.h"

@interface DatePicker()

@property (nonatomic, weak) id listener;
@property (nonatomic) SEL action;
@end

@implementation DatePicker

+(instancetype)datePicker
{
    DatePicker *res = [[DatePicker alloc] initWithFrame:CGRectMake(0, 0, 320, 206)];
    
    res.backgroundColor = [UIColor clearColor];
    res.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"DatePicker" owner:res options:nil] objectAtIndex:0];
    
    view.frame = CGRectMake(0, 206, 320, 206);
    [res addSubview:view];
    
    return res;
}

- (void)dealloc
{
    self.doneBlock = nil;
    self.cancelBlock = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.sendChangedEventOnDone = YES;
        self.doneBlock = nil;
        self.cancelBlock = nil;
        self.continueous = NO;
        
        UIView *underneath = [[UIView alloc] initWithFrame:self.bounds];
        underneath.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        underneath.backgroundColor = [UIColor clearColor];
        [self addSubview:underneath];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCancel:)];
        [underneath addGestureRecognizer:gesture];
    }
    return self;
}

#pragma mark Methods
- (void)presentInView:(UIView *)view animated:(BOOL)animated completion:(void (^)())completion
{
    
    self.frame = view.bounds;
    [view addSubview:self];
    
    if (animated)
    {
        CGRect frame = self.contentView.frame;
        frame.origin.y = CGRectGetMaxY(self.bounds);
        self.contentView.frame = frame;
        
        frame.origin.y = CGRectGetMaxY(self.bounds) - self.contentView.frame.size.height;
        
        [UIView animateWithDuration:0.25 animations:^{
            self.contentView.frame = frame;
        } completion:^(BOOL finished) {
            if (completion) completion();
        }];
    }
    else
    {
        CGRect frame = self.contentView.frame;
        frame.origin.y = CGRectGetMaxY(self.bounds) - self.contentView.frame.size.height;
        self.contentView.frame = frame;
        
        if (completion) completion();
    }
}

- (void)dismissAnimated:(BOOL)animated completion:(void (^)())completion
{
    if (animated)
    {
        CGRect frame = self.contentView.frame;
        frame.origin.y = CGRectGetMaxY(self.bounds);
        
        [UIView animateWithDuration:0.2 animations:^{
            self.contentView.frame = frame;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            if (completion) completion();
        }];
    }
    else
    {
        CGRect frame = self.contentView.frame;
        frame.origin.y = CGRectGetMaxY(self.bounds);
        self.contentView.frame = frame;
        [self removeFromSuperview];
        if (completion) completion();
    }
}

- (void)setValueChangedListener:(id)listener action:(SEL)action
{
    self.listener = listener;
    self.action = action;
}

- (IBAction)onDateChanged:(id)sender
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (self.listener && self.continueous)
    {
        id object = self.listener;
        
        if ([object respondsToSelector:self.action])
            [object performSelector:self.action withObject:self];
    }
#pragma clang diagnostic pop
}

- (IBAction)onDone:(id)sender
{
    if (self.sendChangedEventOnDone && self.listener)
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        
        id object = self.listener;
        
        if ([object respondsToSelector:self.action])
            [object performSelector:self.action withObject:self];
#pragma clang diagnostic pop
    }
    
    __weak DatePicker *wself = self;
    
    [self dismissAnimated:YES completion:^{
        
        __strong DatePicker *sself = wself;
        
        if (sself && sself.doneBlock)
            sself.doneBlock(sself);
    }];
}

- (IBAction)onCancel:(id)sender
{
    __weak DatePicker *wself = self;
    
    [self dismissAnimated:YES completion:^{
        
        __strong DatePicker *sself = wself;
        
        if (sself && sself.cancelBlock)
            sself.cancelBlock(sself);
    }];
}

#pragma mark Properties
- (void)setDatePickerMode:(UIDatePickerMode)datePickerMode
{
    self.datePicker.datePickerMode = datePickerMode;
}

- (UIDatePickerMode)datePickerMode
{
    return self.datePicker.datePickerMode;
}

- (void)setDate:(NSDate *)date
{
    self.datePicker.date = date;
}

- (NSDate *)date
{
    return self.datePicker.date;
}

- (void)setMinimumDate:(NSDate *)minimumDate
{
    self.datePicker.minimumDate = minimumDate;
}

- (NSDate *)minimumDate
{
    return self.datePicker.minimumDate;
}

- (void)setMaximumDate:(NSDate *)maximumDate
{
    self.datePicker.maximumDate = maximumDate;
}

- (NSDate *)maximumDate
{
    return self.datePicker.maximumDate;
}

- (NSTimeInterval)minuteInterval
{
    return self.datePicker.minuteInterval;
}

- (void)setMinuteInterval:(NSTimeInterval)minuteInterval
{
    self.datePicker.minuteInterval = minuteInterval;
}

- (NSString *)title
{
    return self.titleLabel.text;
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}



@end
