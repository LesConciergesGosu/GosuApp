//
//  NMRangeSlider+RuntimeAttributes.m
//  Gosu
//
//  Created by Dragon on 10/12/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "NMRangeSlider+RuntimeAttributes.h"

@implementation NMRangeSlider (RuntimeAttributes)

- (void)setLowerHandleNormalName:(NSString *)lowerHandleNormalName
{
    self.lowerHandleImageNormal = [UIImage imageNamed:lowerHandleNormalName];
}

- (NSString *)lowerHandleNormalName
{
    return nil;
}

- (void)setLowerHandleHighlightedName:(NSString *)lowerHandleHighlightedName
{
    self.lowerHandleImageHighlighted= [UIImage imageNamed:lowerHandleHighlightedName];
}

- (NSString *)lowerHandleHighlightedName
{
    return nil;
}

- (void)setUpperHandleNormalName:(NSString *)upperHandleNormalName
{
    self.upperHandleImageNormal = [UIImage imageNamed:upperHandleNormalName];
}

- (NSString *)upperHandleNormalName
{
    return nil;
}

- (void)setUpperHandleHighlightedName:(NSString *)upperHandleHighlightedName
{
    self.upperHandleImageHighlighted = [UIImage imageNamed:upperHandleHighlightedName];
}

- (NSString *)upperHandleHighlightedName
{
    return nil;
}

- (void)setTrackImageName:(NSString *)trackImageName
{
    UIImage *image = [UIImage imageNamed:trackImageName];
    CGSize size = image.size;
    CGFloat gap = size.width * 0.5 - 1;
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, gap, 0.0, gap)];
    
    self.trackImage = image;
}

- (NSString *)trackImageName
{
    return nil;
}

- (void)setTrackBgImageName:(NSString *)trackBgImageName
{
    UIImage *image = [UIImage imageNamed:trackBgImageName];
    CGSize size = image.size;
    CGFloat gap = size.width * 0.5 - 1;
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, gap, 0.0, gap)];
    self.trackBackgroundImage = image;
}

- (NSString *)trackBgImageName
{
    return nil;
}

- (void)setLowerTouchEdgeString:(NSString *)lowerTouchEdgeString
{
    self.lowerTouchEdgeInsets = UIEdgeInsetsFromString(lowerTouchEdgeString);
}

- (NSString *)lowerTouchEdgeString
{
    return NSStringFromUIEdgeInsets(self.lowerTouchEdgeInsets);
}

- (void)setUpperTouchEdgeString:(NSString *)upperTouchEdgeString
{
    self.upperTouchEdgeInsets = UIEdgeInsetsFromString(upperTouchEdgeString);
}

- (NSString *)upperTouchEdgeString
{
    return NSStringFromUIEdgeInsets(self.upperTouchEdgeInsets);
}

@end
