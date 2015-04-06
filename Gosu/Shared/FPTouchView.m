//
//  FPTouchView.m
//  Gosu
//
//  Created by Dragon on 10/15/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "FPTouchView.h"

@implementation FPTouchView

-(void)dealloc
{
    _outsideBlock = nil;
    _insideBlock = nil;
}

-(void)setTouchedOutsideBlock:(FPTouchedOutsideBlock)outsideBlock
{
    _outsideBlock = nil;
    if (outsideBlock)
        _outsideBlock = [outsideBlock copy];
}

-(void)setTouchedInsideBlock:(FPTouchedInsideBlock)insideBlock
{
    _insideBlock = nil;
    
    if (insideBlock)
        _insideBlock = [insideBlock copy];
}

-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *subview = [super hitTest:point withEvent:event];
    
    if(UIEventTypeTouches == event.type)
    {
        BOOL touchedInside = subview != self;
        if(!touchedInside)
        {
            for(UIView *s in self.subviews)
            {
                if(s == subview)
                {
                    //touched inside
                    touchedInside = YES;
                    break;
                }
            }
        }
        
        if(touchedInside && _insideBlock)
        {
            _insideBlock();
        }
        else if(!touchedInside && _outsideBlock)
        {
            _outsideBlock();
        }
    }
    
    return subview;
}
@end
