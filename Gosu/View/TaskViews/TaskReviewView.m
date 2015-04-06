//
//  TaskReviewView.m
//  Gosu
//
//  Created by dragon on 3/22/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "TaskReviewView.h"
#import "GStarRating.h"
#import "RoundImageView.h"
#import "TaskReviewCell.h"
#import "PTask.h"

#import "Task+Extra.h"
#import "DataManager.h"

@interface TaskReviewView()
@property (nonatomic, strong) NSArray *reviews;
@end

@implementation TaskReviewView
@synthesize task = _task;

- (id) initWithParentView:(UIView *)parentView withTask:(Task *)aTask
{
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"TaskReviewView" owner:self options:nil] objectAtIndex:0];
    
    if ((self = [super initWithParentView:parentView view:view]))
    {
        [view setFrame:[parentView bounds]];
        
        
        [self setTask:aTask];
        
        [self.collectionView registerNib:[UINib nibWithNibName:@"TaskReviewCell" bundle:nil] forCellWithReuseIdentifier:@"taskReviewCell"];
    }
    
    return self;
}

- (void) setTask:(Task *)aTask
{
    _task = aTask;
    
    [self taskTitleLabel].text = aTask.title;
    [self.activityIndicator startAnimating];
    
    __weak typeof (self) wself = self;
    
    [aTask fetchReviewsTodoWithCompletionHandler:^(NSArray *array, NSString *errorDesc) {
        
        TaskReviewView *sself = wself;
        
        if (sself) {
            
            if (errorDesc) {
                [[[UIAlertView alloc] initWithTitle:@"Warning" message:errorDesc delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                [sself.activityIndicator stopAnimating];
                [sself hideWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut completion:nil];
                return;
            }
            
            if ([array count] == 0) {
                [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"There are no persons to rate." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                [sself.activityIndicator stopAnimating];
                [sself hideWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut completion:nil];
                return;
            }
            
            NSMutableArray *reviews = [NSMutableArray arrayWithCapacity:[array count]];
            for (NSDictionary *entry in array) {
                [reviews addObject:[NSMutableDictionary dictionaryWithDictionary:entry]];
            }
            
            sself.reviews = reviews;
            
            [sself.collectionView reloadData];
            [sself.activityIndicator stopAnimating];
        }
    }];
}


#pragma mark Collection View
#pragma mark TableView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self reviews].count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)aCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TaskReviewCell *cell = (TaskReviewCell *)
    [aCollectionView dequeueReusableCellWithReuseIdentifier:@"taskReviewCell" forIndexPath:indexPath];
    
    if (indexPath.item < [self reviews].count)
        [cell setReview:self.reviews[indexPath.item]];
    
    return cell;
}

#pragma mark Actions

- (IBAction)onGo:(id)sender {
    
    __weak typeof (self) wself = self;
    
    [_task rateWithReviews:self.reviews CompletionHandler:^(BOOL success, NSString *errorDesc) {
        
        TaskReviewView *sself = wself;
        if (success) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshTaskListView object:nil];
            
            [[DataManager manager] refreshMyGosuListWithCompletionHandler:nil];
            
            [sself hideWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut completion:^{
                
                TaskReviewView *ssself = wself;
                
                if (ssself.delegate && [self.delegate respondsToSelector:@selector(taskReviewView:didDismissWithReviews:)]) {
                    [ssself.delegate taskReviewView:self didDismissWithReviews:self.reviews];
                }
            }];
            
        } else {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:errorDesc delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }];
}

- (IBAction)onShareFacebook:(id)sender
{
    
}

- (IBAction)onShareTwitter:(id)sender
{
    
}

- (IBAction)onSharePinterest:(id)sender
{
    
}

@end
