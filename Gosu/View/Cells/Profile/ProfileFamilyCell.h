//
//  ProfileFamilyCell.h
//  Gosu
//
//  Created by dragon on 6/4/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemovableCell.h"

@interface ProfileFamilyCell : RemovableCell

@property (nonatomic, strong) IBOutlet UILabel *lblRelation;
@property (nonatomic, strong) IBOutlet UILabel *lblName;
@property (nonatomic, strong) IBOutlet UILabel *lblAddress;
@end
