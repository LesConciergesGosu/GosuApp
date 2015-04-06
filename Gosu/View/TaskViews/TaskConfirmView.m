//
//  TaskConfirmView.m
//  Gosu
//
//  Created by dragon on 3/22/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "TaskConfirmView.h"

@implementation TaskConfirmView

- (id) initWithParentView:(UIView *)parentView
{
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"TaskConfirmView" owner:self options:nil] objectAtIndex:0];
    
    if ((self = [super initWithParentView:parentView view:view])) {
        [view setFrame:[parentView bounds]];
    }
    return self;
}

- (void) setBilledCardAmount:(int)billedCardAmount andCredits:(int)credits inHours:(int)hours {
    
    if (credits < 2)
        [self lblCredits].text = [NSString stringWithFormat:@"%d credit", credits];
    else
        [self lblCredits].text = [NSString stringWithFormat:@"%d credits", credits];
    
    [self lblCreditAmount].text = [NSString stringWithFormat:@"$%d", credits * 25];
    [self lblCardAmount].text = [NSString stringWithFormat:@"$%d", billedCardAmount];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Total $%d", billedCardAmount + credits * 25]];
    NSDictionary *attributes = @{UITextAttributeFont:[UIFont boldSystemFontOfSize:25],
        UITextAttributeTextColor:APP_COLOR_TEXT_BLACK};
    [string addAttributes:attributes
                    range:NSMakeRange(0, 5)];
    
    attributes = @{UITextAttributeFont:[UIFont boldSystemFontOfSize:25],
                   UITextAttributeTextColor:APP_COLOR_GREEN};
    [string addAttributes:attributes
                    range:NSMakeRange(6, [string length] - 6)];
    
    [self lblTotalAmount].attributedText = string;
}

- (void) setRedactedCardNumber:(NSString *)cardNumber
{
    [self lblCardNumber].text = cardNumber;
}

#pragma mark Actions

- (IBAction)onCancel:(id)sender
{
    [self hideWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(taskConfrimView:didDismissWithResult:)])
        {
            [self.delegate taskConfrimView:self didDismissWithResult:NO];
        }
    }];
}

- (IBAction)onGo:(id)sender
{
    [self hideWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(taskConfrimView:didDismissWithResult:)])
        {
            [self.delegate taskConfrimView:self didDismissWithResult:YES];
        }
    }];
}

@end
