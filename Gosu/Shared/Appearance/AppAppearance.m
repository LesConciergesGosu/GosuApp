//
//  AppAppearnce.m
//  Gosu
//
//  Created by Dragon on 10/13/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "AppAppearance.h"

#define NAV_BUTTON_FONT [UIFont fontWithName:@"GothamRounded-Bold" size:10]

static UIColor *patternBGColor = nil;

@implementation AppAppearance

+ (UIBarButtonItem *)backBarButtonItemWithTarget:(id)target action:(SEL)action {
    
    
    return [AppAppearance backBarButtonItemWithTitle:nil target:target action:action];
    
}

+ (UIBarButtonItem *)backBarButtonItemWithTitle:(NSString *)t target:(id)target action:(SEL)action {
    
    
    UIImage *backImage = [UIImage imageNamed:@"nav_back"];
    UIImage *backImageHighlighted = [UIImage imageNamed:@"nav_back_highlighted"];
    
    
    NSString *title = t ? t : @"BACK";
    
    CGRect frame = CGRectMake(0, 0, 60, 30);
    
    CGSize sz;
    
    if ([title respondsToSelector:@selector(sizeWithAttributes:)]) {
        
        sz = [title sizeWithAttributes:@{NSFontAttributeName:NAV_BUTTON_FONT}];
        
    } else {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        
        sz = [title sizeWithFont:NAV_BUTTON_FONT constrainedToSize:CGSizeMake(1000, 30)];
        
#pragma clang diagnostic pop
        
    }
    
    frame.size.width = sz.width + backImage.size.width - 6;
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setImage:backImage forState:UIControlStateNormal];
    
    [button setImage:backImageHighlighted forState:UIControlStateHighlighted];
    
    [button setImageEdgeInsets:UIEdgeInsetsMake(-1, -16, 0, 0)];
    
    [button setTitleColor:[AppAppearance linkColor] forState:UIControlStateNormal];
    
    [button setTitleColor:[AppAppearance linkHighlightedColor] forState:UIControlStateHighlighted];
    
    [button setTitle:title forState:UIControlStateNormal];
    
    [button setTitleEdgeInsets:UIEdgeInsetsMake(1, -12, 0, 0)];
    
    [button.titleLabel setFont:NAV_BUTTON_FONT];
    
    [button.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    
    [button setFrame:frame];
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    
    return [[UIBarButtonItem alloc] initWithCustomView:button];
    
}

+ (UIColor *)viewPatternColor
{
    if (patternBGColor == nil)
        patternBGColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_pattern"]];
    
    return patternBGColor;
}

+ (NSString *)viewPatternName
{
    return @"bg_pattern";
}

+ (UIColor *)darkTextColor
{
    return [UIColor colorWithRed:67/255.f green:86/255.f blue:99/255.f alpha:1];
}

+ (UIColor *)linkColor
{
    //4fbbcb
    return [UIColor whiteColor];
}

+ (UIColor *)linkHighlightedColor
{
    //d6ebef
    return [[UIColor whiteColor] colorWithAlphaComponent:.4];
}


@end
