//
//  GRadialProgressView.m
//  Gosu
//
//  Created by dragon on 4/10/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "GRadialProgressView.h"
#import <MDRadialProgress/MDRadialProgressTheme.h>
#import <MDRadialProgress/MDRadialProgressLabel.h>

@implementation GRadialProgressView


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.theme.sliceDividerHidden = YES;
    self.label.hidden = YES;
    self.progressTotal = 100;
    self.progressCounter = 1;
}

@end
