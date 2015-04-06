//
//  TaskCustomerCell.m
//  Gosu
//
//  Created by Dragon on 10/14/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "TaskCustomerCell.h"
#import "GStarRating.h"
#import "RoundImageView.h"
#import "NSDate+Task.h"
#import "Task+Extra.h"
#import "User+Extra.h"

#import "DataManager.h"

@interface TaskCustomerCell()
@property (nonatomic, weak) Task *task_;
@property (nonatomic, weak) User *user_;
@end

@implementation TaskCustomerCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.topImageView.image = nil;
}

- (void)setTask:(Task *)aTask
{
    self.task_ = aTask;
    
    if (aTask == nil)
        return;
    
    self.typeLabel.text = [Task shortTitleForType:aTask.type subType:aTask.type2];
    self.typeLabel.textColor = [Task colorForType:aTask.type];
    self.titleLabel.text = aTask.title;
    
    if (aTask.customer == [User currentUser]) // created myself
    {
        User *employee = [aTask mainWorker];
        
        if (!employee)
        {
            [self employeeInfoView].hidden = YES;
            [self employeeGosuImageView].hidden = YES;
        }
        else
        {
            [self displayUserInfo:employee];
        }
        
        if (aTask.date && self.lblDate)
        {
            if ([aTask.asap boolValue])
                self.lblDate.text = @"ASAP";
            else
                self.lblDate.attributedText = [aTask.date attributedDateTimeWithSize:12 forTaskType:aTask.type];
        }
        
        if (aTask.date2 && self.lblDate2)
            self.lblDate2.attributedText = [aTask.date2 attributedDateTimeWithSize:12 forTaskType:aTask.type];
        
        
        if (self.lblPersons)
        {
            
            if ([aTask.numberOfAdults intValue] > 0 && self.lblPersons)
            {
                NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
                [string appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", aTask.numberOfAdults] attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Medium" size:16]}]];
                [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"adults" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Medium" size:9]}]];
                
                if ([aTask.numberOfChildren intValue] > 0)
                {
                    [string appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ ", aTask.numberOfChildren] attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Medium" size:16]}]];
                    [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"children" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Medium" size:9]}]];
                }
                
                if ([aTask.numberOfInfants intValue] > 0)
                {
                    [string appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ ", aTask.numberOfInfants] attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Medium" size:16]}]];
                    [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"infants" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Medium" size:9]}]];
                }
                
                self.lblPersons.attributedText = string;
            }
            else if ([aTask.numberOfPersons intValue] > 0)
            {
                NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
                [string appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", aTask.numberOfPersons] attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Medium" size:16]}]];
                [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"guests" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Medium" size:9]}]];
                
                self.lblPersons.attributedText = string;
            }
            else
                self.lblPersons.text = @"";
        }
        
        if ([aTask.priceLevel intValue] > 0)
        {
            self.lblCost.text = [@"" stringByPaddingToLength:[aTask.priceLevel intValue] withString:@"$" startingAtIndex:0];
        }
        else
        {
            self.lblCost.text = [NSString stringWithFormat:@"$%d - $%d", (int)[aTask.lowerPrice floatValue], (int)[aTask.upperPrice floatValue]];
        }
    }
    
    [self badgeView].hidden = ([aTask.unread intValue] == 0);
}

- (void) displayUserInfo:(User *)user {
    
    self.user_ = user;
    
    [self employeeInfoView].hidden = NO;
    [self employeeGosuImageView].hidden = ![user isGosu];
    [self employeeNameLabel].text = [user fullName];
    [self employeeRatingControl].rating = [user.rating floatValue];
    
    [self employeePhotoView].image = [UIImage imageNamed:@"buddy"];
    NSString *photoUrlString = [user photo];
    if (photoUrlString)
    {
        __weak TaskCustomerCell *wself = self;
        [[DataManager manager] loadImageURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:photoUrlString]] handler:^(UIImage *image) {
            TaskCustomerCell *sself = wself;
            if (sself && sself.user_ == user && image) {
                [sself employeePhotoView].image = image;
            }
        }];
    }
}

- (IBAction)onMessages:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(taskCustomerCellMessages:)])
        [self.delegate taskCustomerCellMessages:self];
}


@end
