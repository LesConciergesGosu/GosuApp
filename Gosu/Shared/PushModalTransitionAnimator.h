//
//  PushModalTransitionAnimator.h
//  Gosu
//
//  Created by Dragon on 10/28/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PushModalTransitionAnimator : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic) BOOL presenting;
@end
