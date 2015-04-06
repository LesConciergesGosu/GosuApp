//
//  UIApplication+NetworkActivityIndicator.m
//  Gosu
//
//  Created by dragon on 3/31/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "UIApplication+NetworkActivityIndicator.h"
#import <libkern/OSAtomic.h>

@implementation UIApplication (NetworkActivityIndicator)

static volatile int32_t numberOfActiveNetworkConnections;

- (void) beganNetworkActivity
{
    self.networkActivityIndicatorVisible = OSAtomicAdd32(1, &numberOfActiveNetworkConnections) > 0;
}

- (void) endNetworkActivity
{
    self.networkActivityIndicatorVisible = OSAtomicAdd32(-1, &numberOfActiveNetworkConnections) > 0;
}

@end
