//
//  UIApplication+NetworkActivityIndicator.h
//  Gosu
//
//  Created by dragon on 3/31/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (NetworkActivityIndicator)

- (void) beganNetworkActivity;
- (void) endNetworkActivity;
@end
