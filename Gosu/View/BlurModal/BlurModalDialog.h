//
//  BlurModalDialog.h
//  Gosu
//
//  Created by dragon on 3/22/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlurModalView.h"
@interface BlurModalDialog : BlurModalView

- (id)initWithTitle:(NSString*)title message:(NSString*)message;
- (id)initWithTitle:(NSString*)title message:(NSString*)message fromView:(UIView *)parentView;
@end
