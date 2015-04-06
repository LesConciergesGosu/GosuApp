//
//  PopoverView.h
//  Gosu
//
//  Created by Dragon on 12/22/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PopoverArrowDirectionDefault = 0,
    
    PopoverArrowDirectionUp = 1UL << 0,
    PopoverArrowDirectionDown = 1UL << 1,
    PopoverArrowDirectionLeft = 1UL << 2,
    PopoverArrowDirectionRight = 1UL << 3,
    
    PopoverArrowDirectionVertical = PopoverArrowDirectionUp | PopoverArrowDirectionDown,
    PopoverArrowDirectionHorizontal = PopoverArrowDirectionLeft | PopoverArrowDirectionRight,
    
    PopoverArrowDirectionAny = PopoverArrowDirectionUp | PopoverArrowDirectionDown |
    PopoverArrowDirectionLeft | PopoverArrowDirectionRight
    
} PopoverArrowDirection;

@interface PopoverView : UIView

@property (nonatomic) PopoverArrowDirection direction;
@end
