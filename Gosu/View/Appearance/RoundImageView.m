//
//  RoundImageView.m
//  Gosu
//
//  Created by dragon on 3/23/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "RoundImageView.h"

@implementation RoundImageView
@synthesize image = _image;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setImage:(UIImage *)image
{
    if (_image == image)
        return;
    
    _image = image;
    [self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect
{
    if (_image)
    {
        [[UIBezierPath bezierPathWithOvalInRect:self.bounds] addClip];
        [_image drawInRect:rect];
    }
}

@end
