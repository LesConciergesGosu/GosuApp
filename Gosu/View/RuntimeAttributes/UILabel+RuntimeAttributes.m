//
//  UILabel+RuntimeAttributes.m
//  Gosu
//
//  Created by Dragon on 9/30/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "UILabel+RuntimeAttributes.h"

@implementation UILabel (RuntimeAttributes)

- (NSString *)fontName
{
    return self.font.fontName;
}

- (void)setFontName:(NSString *)fontName
{
    self.font = [UIFont fontWithName:fontName size:self.font.pointSize];
}

@end
