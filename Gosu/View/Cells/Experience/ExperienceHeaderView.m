//
//  ExperienceHeaderView.m
//  Gosu
//
//  Created by Dragon on 11/26/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "ExperienceHeaderView.h"

@implementation ExperienceHeaderView

- (void)dealloc
{
    _buttonBlock = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setTapButtonBlock:(ObjectBlock)block
{
    _buttonBlock = nil;
    if (block)
        _buttonBlock = [block copy];
}

- (IBAction)onTapButton:(id)sender
{
    if (_buttonBlock)
        _buttonBlock(self);
}

@end
