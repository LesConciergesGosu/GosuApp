//
//  UILabel+AutoHeight.m
//  Gosu
//
//  Created by dragon on 3/22/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "UILabel+AutoHeight.h"

@implementation UILabel (AutoHeight)
- (void)autoHeight {
    CGRect frame = self.frame;
    CGSize maxSize = CGSizeMake(frame.size.width, 9999);
    CGSize expectedSize = [self.text sizeWithFont:self.font constrainedToSize:maxSize lineBreakMode:self.lineBreakMode];
    frame.size.height = expectedSize.height;
    [self setFrame:frame];
}
@end
