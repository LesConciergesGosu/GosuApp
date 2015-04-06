//
//  NMRangeSlider+RuntimeAttributes.h
//  Gosu
//
//  Created by Dragon on 10/12/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "NMRangeSlider.h"

@interface NMRangeSlider (RuntimeAttributes)

@property (nonatomic, copy) NSString *lowerHandleNormalName;
@property (nonatomic, copy) NSString *lowerHandleHighlightedName;
@property (nonatomic, copy) NSString *upperHandleNormalName;
@property (nonatomic, copy) NSString *upperHandleHighlightedName;
@property (nonatomic, copy) NSString *trackImageName;
@property (nonatomic, copy) NSString *trackBgImageName;

@property (nonatomic, copy) NSString *lowerTouchEdgeString;
@property (nonatomic, copy) NSString *upperTouchEdgeString;
@end
