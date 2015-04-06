//
//  FrameButton.m
//  Gosu
//
//  Created by Dragon on 9/29/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "FrameButton.h"

#import <QuartzCore/QuartzCore.h>

static CGFloat const SWDefaultFontSize        = 15.0;
static CGFloat const SWCornerRadius           = 4.0;
static CGFloat const SWBorderWidth            = 1.0;
static CGFloat const SWAnimationDuration      = 0.25;
static UIEdgeInsets const SWContentEdgeInsets = {5, 10, 5, 10};

@implementation FrameButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
        [self setupDefaultConfiguration];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.layer.cornerRadius = SWCornerRadius;
    self.layer.borderWidth = SWBorderWidth;
    self.layer.borderColor = self.tintColor.CGColor;
    [self setContentEdgeInsets:SWContentEdgeInsets];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected|UIControlStateHighlighted];
    [self setTitleColor:self.tintColor forState:UIControlStateNormal];
}

- (void)setupDefaultConfiguration
{
    [self.titleLabel setFont:[UIFont systemFontOfSize:SWDefaultFontSize]];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    [UIView animateWithDuration:SWAnimationDuration animations:^{
        if (highlighted) {
            if (self.selected) {
                //CGFloat r, g, b;
                //[self.tintColor getRed:&r green:&g blue:&b alpha:nil];
                //self.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:0.5];
                self.layer.borderColor = [UIColor clearColor].CGColor;
            } else {
                
                CGFloat r, g, b;
                [self.tintColor getRed:&r green:&g blue:&b alpha:nil];
                //self.backgroundColor = [UIColor clearColor];
                self.layer.borderColor = [UIColor colorWithRed:r green:g blue:b alpha:0.15].CGColor;
            }
        } else {
            self.layer.borderColor = self.tintColor.CGColor;
            if (self.selected) {
                //self.backgroundColor = self.tintColor;
            } else {
                //self.backgroundColor = [UIColor clearColor];
            }
        }
        
    }];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        //self.backgroundColor = self.tintColor;
    } else {
        //self.backgroundColor = [UIColor clearColor];
    }
}

- (void)tintColorDidChange
{
    self.layer.borderColor = self.tintColor.CGColor;
    [self setTitleColor:self.tintColor forState:UIControlStateNormal];
    if (self.selected) {
        //self.backgroundColor = self.tintColor;
    }
}

#pragma mark User Defined Custom Runtime Attributes
- (NSString *)fontName {
    return self.titleLabel.font.fontName;
}

- (void)setFontName:(NSString *)fontName
{
    self.titleLabel.font = [UIFont fontWithName:fontName size:self.titleLabel.font.pointSize];
}


@end
