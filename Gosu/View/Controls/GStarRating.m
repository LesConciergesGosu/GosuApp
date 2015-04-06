//
//  GStarRating.m
//  Gosu
//
//  Created by dragon on 3/19/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "GStarRating.h"

@implementation GStarRating
@synthesize minRating = _minRating;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (void) initialize
{
    self.starImage = [UIImage imageNamed:@"star_icon"];
    self.starHighlightedImage = [UIImage imageNamed:@"star_icon_highlight"];
    self.maxRating = 5;
    self.horizontalMargin = 2;
    self.displayMode = EDStarRatingDisplayAccurate;
    self.rating = 0;
    
    _minRating = 0;
    
    [self setNeedsDisplay];
}

- (void) setMinRating:(CGFloat)minRating
{
    _minRating = minRating;
    
    [self setNeedsDisplay];
}

//Override
- (void) setRating:(float)ratingParam
{
    if (ratingParam >= _minRating)
        [super setRating:ratingParam];
}

- (CGPoint) pointOfStarAtPosition:(NSInteger)position highlighted:(BOOL)hightlighted
{
    CGSize size = hightlighted?self.starHighlightedImage.size:self.starImage.size;
    
    NSInteger starsSpace = self.bounds.size.width - 2*self.horizontalMargin;
    
    NSInteger interSpace = 0;
    interSpace = self.maxRating-1>0?(starsSpace - (self.maxRating)*size.width)/(self.maxRating-1):0;
    if( interSpace <0 )
        interSpace=0;
    CGFloat x = self.horizontalMargin + size.width*position;
    if( position >0 )
        x+=interSpace*position;
    CGFloat y = (self.bounds.size.height - size.height)/2.0;
    return CGPointMake(x  ,y);
}

- (float) starsForPoint:(CGPoint)point
{
    float stars=self.minRating;
    for( NSInteger i=0; i<self.maxRating; i++ )
    {
        CGPoint p = [self pointOfStarAtPosition:i highlighted:NO];
        CGPoint np = [self pointOfStarAtPosition:i + 1 highlighted:NO];
        if( p.x < point.x && point.x < np.x)
        {
            stars = i;
            
            if( self.displayMode == EDStarRatingDisplayHalf  )
            {
                float difference = (point.x - p.x)/self.starImage.size.width;
                if( difference < self.halfStarThreshold )
                {
                    stars = i + 0.5;
                }
            }
            else if (self.displayMode == EDStarRatingDisplayAccurate)
            {
                float difference = (point.x - p.x) / self.starImage.size.width;
                
                stars = i + MIN(difference, 1);
            }
            
            break;
        } else if (point.x >= np.x) {
            stars = i + 1;
        } else if (p.x < point.x) {
            stars = i;
        }
    }
    
    stars = roundf(stars * 10.f);
    stars = stars / 10.f;
    
    return stars;
}

@end
