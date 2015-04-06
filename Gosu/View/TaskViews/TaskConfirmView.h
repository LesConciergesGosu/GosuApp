//
//  TaskConfirmView.h
//  Gosu
//
//  Created by dragon on 3/22/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "BlurModalView.h"

@class TaskConfirmView;
@protocol TaskConfirmViewDelegate <NSObject>

@optional
- (void) taskConfrimView:(TaskConfirmView *)view didDismissWithResult:(BOOL)result;

@end

@interface TaskConfirmView : BlurModalView

@property (nonatomic, weak) IBOutlet UILabel *lblCredits;
@property (nonatomic, weak) IBOutlet UILabel *lblCreditAmount;
@property (nonatomic, weak) IBOutlet UILabel *lblCardAmount;
@property (nonatomic, weak) IBOutlet UILabel *lblCardNumber;
@property (nonatomic, weak) IBOutlet UILabel *lblTotalAmount;
@property (weak) id<TaskConfirmViewDelegate> delegate;
- (id) initWithParentView:(UIView *)parentView;
- (void) setBilledCardAmount:(int)billedCardAmount andCredits:(int)credits inHours:(int)hours;
- (void) setRedactedCardNumber:(NSString *)cardNumber;
@end
