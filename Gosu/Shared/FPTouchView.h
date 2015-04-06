//
//  FPTouchView.h
//  Gosu
//
//  Created by Dragon on 10/15/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^FPTouchedOutsideBlock)();
typedef void (^FPTouchedInsideBlock)();

@interface FPTouchView : UIView
{
    FPTouchedOutsideBlock _outsideBlock;
    FPTouchedInsideBlock  _insideBlock;
}

-(void)setTouchedOutsideBlock:(FPTouchedOutsideBlock)outsideBlock;

-(void)setTouchedInsideBlock:(FPTouchedInsideBlock)insideBlock;
@end