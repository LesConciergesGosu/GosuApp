//
//  TaskDetailViewController.m
//  Gosu
//
//  Created by Dragon on 10/14/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "TaskDetailViewController.h"
#import "DataManager.h"
#import "User+Extra.h"
#import "Task+Extra.h"
#import "NSDate+Task.h"
#import "GStarRating.h"
#import "TaskMessageViewController.h"
#import "RoundImageView.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

@interface TaskDetailViewController ()

@end

@implementation TaskDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.task)
    {
        self.title = [self.task navigationTitle];
        [self loadData];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshStatus:)
                                                 name:NotificationRefreshTaskListView
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    [self refreshStatus:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Private

- (void)refreshStatus:(id)sender
{
    if (self.task.customer == [User currentUser])
    {
        switch ([self.task.status intValue]) {
            case TaskStatusCreated:
                self.lblStatus.text = @"NOT ASSIGNED";
                self.btnDone.hidden = YES;
                break;
            case TaskStatusAssigned:
                self.lblStatus.text = @"IN PROGRESS";
                self.btnDone.hidden = YES;
                break;
            case TaskStatusFinished:
                self.lblStatus.text = @"COMPLETED";
                [self.btnDone setTitle:@"RATE NOW!" forState:UIControlStateNormal];
                self.btnDone.hidden = NO;
                break;
            case TaskStatusReviewed:
                self.lblStatus.text = @"COMPLETED";
                self.btnDone.hidden = YES;
                break;
            default:
                break;
        }
    }
    else
    {
        switch ([self.task.status intValue]) {
            case TaskStatusCreated:
                self.lblStatus.text = @"NOT ASSIGNED";
                self.btnDone.hidden = YES;
                break;
            case TaskStatusAssigned:
                self.lblStatus.text = @"IN PROGRESS";
                [self.btnDone setTitle:@"FINISH" forState:UIControlStateNormal];
                self.btnDone.hidden = NO;
                break;
            case TaskStatusFinished:
                self.lblStatus.text = @"COMPLETED";
                [self.btnDone setTitle:@"RATE NOW!" forState:UIControlStateNormal];
                self.btnDone.hidden = NO;
                break;
            case TaskStatusReviewed:
                self.lblStatus.text = @"COMPLETED";
                self.btnDone.hidden = YES;
                break;
            default:
                break;
        }
    }
    
    if (self.badgeView)
        [self badgeView].hidden = ([self.task.unread intValue] == 0);
}

- (void)loadData
{
    
    Task *task = self.task;
    
    
    if (task.customer == [User currentUser])
    {
        self.lblTitle.text = task.title;
        self.lblType.text = [Task shortTitleForType:task.type subType:task.type2];
        
        
        User *user = [task mainWorker];
        
        if (!user)
        {
            self.gosuView.hidden = YES;
        }
        else
        {
            self.gosuView.hidden = NO;
            self.lblName.text = user.fullName;
            self.userRatingControl.rating = [user.rating floatValue];
            self.photoView.image = [UIImage imageNamed:@"buddy"];
            NSString *photoUrlString = [user photo];
            if (photoUrlString)
            {
                __weak TaskDetailViewController *wself = self;
                [[DataManager manager] loadImageURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:photoUrlString]] handler:^(UIImage *image) {
                    TaskDetailViewController *sself = wself;
                    if (sself && image) {
                        [sself photoView].image = image;
                    }
                }];
            }
        }
        
        [self loadDetails];
    }
}


- (void) loadDetails
{
    
    Task *task = self.task;
    
    if (!self.task)
    {
        return;
    }
    
    if (task.photoUrl)
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:task.photoUrl]];
        
        UIImage *image = [[UIImageView sharedImageCache] cachedImageForRequest:request];
        
        if (image)
        {
            self.taskCoverImageView.image = image;
        }
        else
        {
            [self.taskCoverImageView setImageWithURLRequest:request placeholderImage:nil success:nil failure:nil];
        }
    }
    
    if ([task.type2 isEqualToString:TASK_TYPE_FLIGHT] ||
        [task.type isEqualToString:TASK_TYPE_ACCOMODATION])
    {
        
        NSString *nibName = [NSString stringWithFormat:@"TaskDetail%@", [task.type capitalizedString]];
        UIView *view = [[[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] objectAtIndex:0];
        
        CGRect frame = view.frame;
        CGRect targetFrame = self.detailView.frame;
        frame.origin = CGPointMake(0, 0);
        frame.size.width = targetFrame.size.width;
        view.frame = frame;
        
        targetFrame.size.height = frame.size.height;
        [self.detailView addSubview:view];
        
        frame = self.contentView.frame;
        frame.size.height = CGRectGetMaxY(targetFrame) + 70;
        self.contentView.frame = frame;
        
        if (task.date && self.lblDate)
            self.lblDate.attributedText = [task.date attributedDateTimeWithSize:12];
        
        if (task.date2 && self.lblDate2)
            self.lblDate2.attributedText = [task.date2 attributedDateTimeWithSize:12];
        
        if ([task.numberOfAdults intValue] > 0 && self.lblPersons)
        {
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", task.numberOfAdults] attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Medium" size:16]}]];
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"adults" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Medium" size:9]}]];
            
            if ([task.numberOfChildren intValue] > 0)
            {
                [string appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ ", task.numberOfChildren] attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Medium" size:16]}]];
                [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"children" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Medium" size:9]}]];
            }
            
            if ([task.numberOfInfants intValue] > 0)
            {
                [string appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ ", task.numberOfInfants] attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Medium" size:16]}]];
                [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"infants" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Medium" size:9]}]];
            }
            
            self.lblPersons.attributedText = string;
        }
        else
        {
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", task.numberOfPersons] attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Medium" size:16]}]];
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"guests" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Medium" size:9]}]];
            
            self.lblPersons.attributedText = string;
        }
        
        if (self.lblCost)
        {
            NSString *price = @"";
            if ([task.priceLevel intValue] > 0)
            {
                price = [@"" stringByPaddingToLength:[task.priceLevel intValue] withString:@"$" startingAtIndex:0];
            }
            else
            {
                price = [NSString stringWithFormat:@"$%d - $%d", [task.lowerPrice intValue], [task.upperPrice intValue]];
            }
            
            self.lblCost.text = [NSString stringWithFormat:@"%@   (PERSONAL CARD)", price];
        }
        
        if (self.lblNote)
            self.lblNote.text = task.note;
        
        self.scrollView.contentSize = self.contentView.bounds.size;
    }
    else if ([task.type isEqualToString:TASK_TYPE_ENTERTAINMENT] ||
             [task.type isEqualToString:TASK_TYPE_FOOD])
    {
        
        CGRect detailFrame = self.detailView.frame;
        CGFloat width = detailFrame.size.width;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 1000)];
        view.backgroundColor = [UIColor clearColor];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        CGFloat yOffset = 20;
        
        if (task.desc)
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, yOffset, width - 30, 20)];
            label.numberOfLines = 0;
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont fontWithName:@"GothamRounded-Book" size:12];
            label.text = task.desc;
            [view addSubview:label];
            
            CGRect lblFrame = label.frame;
            lblFrame.size.height = [label sizeThatFits:lblFrame.size].height;
            label.frame = lblFrame;
            
            yOffset = CGRectGetMaxY(lblFrame) + 20;
        }
        
        if (task.address)
        {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, yOffset, 20, 35)];
            imgView.contentMode = UIViewContentModeCenter;
            imgView.image = [UIImage imageNamed:@"task_pin"];
            [view addSubview:imgView];
            
            NSString *address = [task.address stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.frame = CGRectMake(44, yOffset, width, 35);
            button.tintColor = [UIColor whiteColor];
            button.titleLabel.font = [UIFont fontWithName:@"GothamRounded-Medium" size:12];
            [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [button setTitle:address forState:UIControlStateNormal];
            [button addTarget:self action:@selector(pickLocation:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button];
            
            yOffset += 35;
        }
        
        if (task.date)
        {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, yOffset, 20, 35)];
            imgView.contentMode = UIViewContentModeCenter;
            imgView.image = [UIImage imageNamed:@"asap_clock_white"];
            [view addSubview:imgView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(44, yOffset, width, 35)];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            label.textColor = [UIColor whiteColor];
            label.attributedText = [task.date attributedDateTimeWithSize:12 forTaskType:task.type];
            [view addSubview:label];
            
            yOffset += 35;
        }
        
        if ([task.numberOfPersons intValue] > 0)
        {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, yOffset, 20, 35)];
            imgView.contentMode = UIViewContentModeCenter;
            imgView.image = [UIImage imageNamed:@"buddies"];
            [view addSubview:imgView];
            
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", task.numberOfPersons] attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Medium" size:16]}]];
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"guests" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Medium" size:9]}]];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(44, yOffset, width, 35)];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            label.textColor = [UIColor whiteColor];
            label.attributedText = string;
            [view addSubview:label];
            
            yOffset += 35;
        }
        
        
        {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, yOffset, 20, 35)];
            imgView.contentMode = UIViewContentModeCenter;
            imgView.image = [UIImage imageNamed:@"icon_card2"];
            [view addSubview:imgView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(44, yOffset, width, 35)];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont fontWithName:@"GothamRounded-Medium" size:12];
            [view addSubview:label];
            
            if ([task.priceLevel intValue] > 0)
            {
                label.text = [@"" stringByPaddingToLength:[task.priceLevel intValue] withString:@"$" startingAtIndex:0];
            }
            else
            {
                label.text = [NSString stringWithFormat:@"$%d - $%d", (int)[task.lowerPrice floatValue], (int)[task.upperPrice floatValue]];
            }
            
            yOffset += 35;
        }
        
        if ([task.note length] > 0)
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, yOffset, width, 20)];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont fontWithName:@"GothamRounded-Bold" size:12];
            label.text = @"NOTES";
            [view addSubview:label];
            
            label = [[UILabel alloc] initWithFrame:CGRectMake(15, yOffset + 20, width, 20)];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont fontWithName:@"GothamRounded-Book" size:12];
            label.text = task.note;
            [view addSubview:label];
            
            CGRect lblFrame = label.frame;
            lblFrame.size.height = [label sizeThatFits:lblFrame.size].height;
            label.frame = lblFrame;
            
            yOffset = CGRectGetMaxY(lblFrame) + 10;
        }
        
        
        CGRect frame = view.frame;
        CGRect targetFrame = self.detailView.frame;
        frame.origin = CGPointMake(0, 0);
        frame.size.width = targetFrame.size.width;
        frame.size.height = yOffset;
        view.frame = frame;
        
        targetFrame.size.height = frame.size.height;
        [self.detailView addSubview:view];
        
        frame = self.contentView.frame;
        frame.size.height = CGRectGetMaxY(targetFrame) + 70;
        self.contentView.frame = frame;
        
        self.scrollView.contentSize = self.contentView.bounds.size;
    }
    
}


#pragma mark Action

- (void) pickLocation:(id)sender
{
    
}

- (IBAction)onCompleteTask:(id)sender
{
    
    if (self.task.customer == [User currentUser])
    {
        switch ([self.task.status intValue]) {
            case TaskStatusCreated:
                break;
            case TaskStatusAssigned:
                break;
            case TaskStatusFinished:
                [[AppDelegate sharedInstance].rootViewController openTaskReviewModalForTask:self.task];
                break;
            case TaskStatusReviewed:
                break;
            default:
                break;
        }
    }
    else
    {
        switch ([self.task.status intValue]) {
            case TaskStatusCreated:
                self.lblStatus.text = @"NOT ASSIGNED";
                self.btnDone.hidden = YES;
                break;
            case TaskStatusAssigned:
            {
                [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
                
                __weak typeof (self) wself = self;
                
                [self.task deliverTaskWithCompletionHandler:^(BOOL success, NSString *errorDesc) {
                    
                    [SVProgressHUD dismiss];
                    
                    TaskDetailViewController *sself = wself;
                    
                    if (!sself)
                        return;
                    
                    [sself refreshStatus:nil];
                    
                    if (!success) {
                        [[[UIAlertView alloc] initWithTitle:@"Warning" message:errorDesc delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    }
                }];
            }
                break;
            case TaskStatusFinished:
                [[AppDelegate sharedInstance].rootViewController openTaskReviewModalForTask:self.task];
                break;
            case TaskStatusReviewed:
                break;
            default:
                break;
        }
    }
    
}

- (IBAction)onGoMessages:(id)sender
{
    [self performSegueWithIdentifier:@"Messages" sender:nil];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[TaskMessageViewController class]])
    {
        [(TaskMessageViewController *)segue.destinationViewController setTask:self.task];
    }
}

@end
