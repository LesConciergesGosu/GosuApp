//
//  UIButton+RuntimeAttributes.m
//  Gosu
//
//  Created by Dragon on 10/12/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "UIButton+RuntimeAttributes.h"

@implementation UIButton (RuntimeAttributes)
- (NSInteger)numberOfLines
{
    return self.titleLabel.numberOfLines;
}

- (void)setNumberOfLines:(NSInteger)numberOfLines
{
    self.titleLabel.numberOfLines = numberOfLines;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (NSString *)fontName
{
    return self.titleLabel.font.fontName;
}

- (void)setFontName:(NSString *)fontName
{
    self.titleLabel.font = [UIFont fontWithName:fontName size:self.titleLabel.font.pointSize];
}

@end
