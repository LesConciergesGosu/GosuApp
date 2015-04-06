//
//  UITextField+RuntimeAttributes.h
//  Gosu
//
//  Created by Dragon on 10/12/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (RuntimeAttributes)

@property (nonatomic, copy) UIColor *placeholderColor;
@property (nonatomic, copy) UIColor *borderColor;
@property (nonatomic, copy) NSString *fontName;
@end
