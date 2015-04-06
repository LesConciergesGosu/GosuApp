//
//  UIView+RuntimeAttributes.h
//  Gosu
//
//  Created by Dragon on 10/12/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (RuntimeAttributes)

@property (nonatomic, strong) NSString *pattern;
@property (nonatomic, copy) UIColor *borderColor;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic, copy) UIColor *shadowColor;
@end
