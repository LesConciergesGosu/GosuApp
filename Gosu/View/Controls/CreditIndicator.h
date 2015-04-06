//
//  CreditIndicator.h
//  Gosu
//
//  Created by dragon on 3/30/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreditIndicator : UIView

@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic, strong) UIColor *fillColor;

/**
 indicate the percent of fill (0...1)
 */
@property (nonatomic) CGFloat percent;
@end
