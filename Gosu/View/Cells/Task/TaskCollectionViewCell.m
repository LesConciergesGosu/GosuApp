//
//  TaskCollectionViewCell.m
//  Gosu
//
//  Created by dragon on 3/23/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "TaskCollectionViewCell.h"
#import "GStarRating.h"
#import "RoundImageView.h"
#import "CreditIndicator.h"
#import "BadgeLabel.h"

#import "Task+Extra.h"
#import "User+Extra.h"

#import "DataManager.h"

@interface TaskCollectionViewCell()
@property (nonatomic, weak) Task *task_;
@property (nonatomic, weak) User *user_;
@end

@implementation TaskCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setTask:(Task *)aTask
{
    self.task_ = aTask;
    
//    if (aTask == nil || [aTask isFault])
//        return;
    
    if (aTask == nil)
        return;
    
    TaskStatus status = [aTask.status intValue];
    int credits = 0;//[aTask.credits intValue];
    int hrs = [aTask.hours intValue];
    
    [self titleLabel].text = aTask.title;
    if (aTask.customer == [User currentUser]) // created myself
    {
        User *employee = [aTask mainWorker];
        
        if (!employee)
        {
            [self employeeInfoView].hidden = YES;
            [self employeeGosuImageView].hidden = YES;
            [self employeeNotAssignedLabel].hidden = NO;
        }
        else
        {
            [self displayUserInfo:employee];
        }
        
        if (credits < 2)
            [self creditsLabel].text = [NSString stringWithFormat:@"%d credit", credits];
        else
            [self creditsLabel].text = [NSString stringWithFormat:@"%d credits", credits];
        
        [self creditsIndicator].percent = credits / 3.f;
        
        if (hrs < 2)
            [self timeLabel].text = [NSString stringWithFormat:@"less than %dhr", hrs];
        else
            [self timeLabel].text = [NSString stringWithFormat:@"less than %dhrs", hrs];
        
        switch (status) {
            case TaskStatusCreated:
                self.statusLabel.text = @"not assigned";
                break;
            case TaskStatusAssigned:
                self.statusLabel.text = @"delivering";
                break;
            case TaskStatusFinished:
                self.statusLabel.text = @"delivered";
                break;
            case TaskStatusReviewed:
                self.statusLabel.text = @"closed";
                break;
            default:
                break;
        }
    } else {
        User *customer = aTask.customer;
        
        if (!customer)
        {
            [self employeeInfoView].hidden = YES;
            [self employeeGosuImageView].hidden = YES;
            [self employeeNotAssignedLabel].hidden = NO;
        }
        else
        {
            [self displayUserInfo:customer];
        }
        
        if (credits < 2)
            [self creditsLabel].text = [NSString stringWithFormat:@"%d credit", credits];
        else
            [self creditsLabel].text = [NSString stringWithFormat:@"%d credits", credits];
        
        [self creditsIndicator].percent = credits / 3.f;
        
        if (hrs < 2)
            [self timeLabel].text = [NSString stringWithFormat:@"less than %dhr", hrs];
        else
            [self timeLabel].text = [NSString stringWithFormat:@"less than %dhrs", hrs];
        
        
        switch (status) {
            case TaskStatusCreated:
                self.statusLabel.text = @"not assigned";
                break;
            case TaskStatusAssigned:
                self.statusLabel.text = @"delivering";
                break;
            case TaskStatusFinished:
                self.statusLabel.text = @"delivered";
                break;
            case TaskStatusReviewed:
                self.statusLabel.text = @"closed";
                break;
            default:
                break;
        }
    }
    
    [self badgeLabel].badgeValue = [aTask.unread integerValue];
}

- (void) displayUserInfo:(User *)user {
    
    self.user_ = user;
    
    [self employeeNotAssignedLabel].hidden = YES;
    [self employeeInfoView].hidden = NO;
    [self employeeNameLabel].text = [user fullName];
    
    [self employeeRatingControl].rating = [user.rating floatValue];
    
    if ([user isGosu])
    {
//        [self employeeInfoView].center = CGPointMake(120, 72);
//        [self employeeGosuImageView].center = CGPointMake(240, 72);
        [self employeeGosuImageView].hidden = NO;
    }
    else
    {
//        [self employeeInfoView].center = CGPointMake(150, 72);
        [self employeeGosuImageView].hidden = YES;
    }
    
    
    [self employeePhotoView].image = [UIImage imageNamed:@"buddy"];
    NSString *photoUrlString = [user photo];
    if (photoUrlString)
    {
        __weak TaskCollectionViewCell *wself = self;
        [[DataManager manager] loadImageURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:photoUrlString]] handler:^(UIImage *image) {
            TaskCollectionViewCell *sself = wself;
            if (sself && sself.user_ == user && image) {
                [sself employeePhotoView].image = image;
            }
        }];
    }
}

@end
