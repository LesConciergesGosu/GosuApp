//
//  AppAppearnce.h
//  Gosu
//
//  Created by Dragon on 10/13/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppAppearance : NSObject

+ (UIBarButtonItem *)backBarButtonItemWithTarget:(id)target action:(SEL)action;
+ (UIBarButtonItem *)backBarButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
+ (UIColor *)darkTextColor;
+ (UIColor *)viewPatternColor;
+ (NSString *)viewPatternName;
@end
