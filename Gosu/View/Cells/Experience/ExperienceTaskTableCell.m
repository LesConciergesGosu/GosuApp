//
//  ExperienceTaskTableCell.m
//  Gosu
//
//  Created by Dragon on 11/27/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "ExperienceTaskTableCell.h"

@interface ExperienceTaskTableCell()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end

@implementation ExperienceTaskTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    
    [super awakeFromNib];
    
}

- (IBAction)onButtonTapped:(id)sender
{
    if (self.buttons)
    {
        [self.delegate experienceTaskTableCell:self tappedButtonAtIndex:[self.buttons indexOfObject:sender]];
    }
    else
    {
        [self.delegate experienceTaskTableCell:self tappedButtonAtIndex:0];
    }
}

#pragma mark Collection View

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize screenSz = [UIScreen mainScreen].bounds.size;
    CGFloat w = MIN(screenSz.width, screenSz.height);
    
    return CGSizeMake(w, w * 0.5);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    if ([self.delegate respondsToSelector:@selector(numberOfRecommendationsForExperienceTaskTableCell:)])
        return [self.delegate numberOfRecommendationsForExperienceTaskTableCell:self];
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.delegate experienceTaskTableCell:self collectionView:collectionView cellForItemAtIndexPath:indexPath];
}

@end
