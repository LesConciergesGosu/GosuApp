//
//  UIButton+RuntimeAttributes.h
//  Gosu
//
//  Created by Dragon on 10/12/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (RuntimeAttributes)

@property (nonatomic) NSInteger numberOfLines;
@property (nonatomic, copy) NSString *fontName;
@end
