//
//  TableHeaderView.m
//  mBrace
//
//  Created by dragon on 5/12/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "TableHeaderView.h"

@implementation TableHeaderView

- (IBAction) onDisclosure:(id)sender {
    [self.delegate onTapHeaderViewDisclosure:self];
}

@end
