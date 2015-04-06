//
//  ProfileInformationCell.h
//  Gosu
//
//  Created by dragon on 5/13/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemovableCell.h"

@interface ProfileInformationCell : RemovableCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *detailLabel;

+ (CGFloat)heightForDetailText:(NSString *)detailText withTitle:(NSString *)title;
- (void) resizeToFit;
@end
