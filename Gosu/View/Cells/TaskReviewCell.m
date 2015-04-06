//
//  TaskReviewCell.m
//  Gosu
//
//  Created by dragon on 3/28/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "TaskReviewCell.h"
#import "GStarRating.h"
#import "RoundImageView.h"
#import "DataManager.h"
#import "User+Extra.h"
#import "PFUser+Extra.h"
#import <Parse/Parse.h>

@interface TaskReviewCell()<EDStarRatingProtocol> {
    CGFloat rating_;
}

@property (nonatomic, strong) NSString *userId;
@end

@implementation TaskReviewCell
@synthesize review = _review;
@synthesize userId = _userId;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setReview:(NSMutableDictionary *)review {
    //update UI
    
    _review = review;
    
    [self ratingView].starImage = [UIImage imageNamed:@"star_big.png"];
    [self ratingView].starHighlightedImage = [UIImage imageNamed:@"star_big_highlight.png"];
    [self ratingView].editable = YES;
    [self ratingView].delegate = self;
    [self ratingView].rating = [_review[@"rating"] floatValue];
    [self ratingView].minRating = 1.0;
    
    
    [self personPhotoView].image = [UIImage imageNamed:@"buddy.png"];
    [self gosuToggleButton].selected = [_review[@"gosu"] boolValue];
    
    [self setPerson:_review[@"toUser"]];
}

- (void) setPerson:(NSString *)userId
{
    self.userId = userId;
    
    [self ratingView].rating = rating_;
    
    NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
    
    User *user = [[DataManager manager] findObjectWithID:userId withEntityName:@"User" inContext:context];
    if (user) {
        [self personNameLabel].text = [user fullName];
        if ([user photo]) {
            
            __weak typeof(self) wself = self;
            [[DataManager manager] loadImageURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[user photo]]] handler:^(UIImage *image) {
                TaskReviewCell *sself = wself;
                if (sself && sself.userId == userId && image) {
                    sself.personPhotoView.image = image;
                }
            }];
        }
    } else {
        
        PFUser *pUser = [PFUser objectWithoutDataWithObjectId:userId];
        
        __weak typeof(self) wself = self;
        [pUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            TaskReviewCell *sself = wself;
            if (sself) {
                PFUser *toUser = (PFUser *)object;
                [sself personNameLabel].text = [toUser fullName];
                
                [[DataManager manager] loadImageURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[toUser photo].url]] handler:^(UIImage *image) {
                    TaskReviewCell *ssself = wself;
                    if (ssself && ssself.userId == userId && image) {
                        ssself.personPhotoView.image = image;
                    }
                }];
            }
        }];
    }
    
}

- (void)starsSelectionChanged:(EDStarRating*)control rating:(float)rating
{
    if (_review) {
        _review[@"rating"] = @(rating);
    }
}

- (IBAction)onToggleGosu:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (_review) {
        _review[@"gosu"] = @(sender.selected);
    }
}
@end
