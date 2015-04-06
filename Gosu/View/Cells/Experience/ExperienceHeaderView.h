//
//  ExperienceHeaderView.h
//  Gosu
//
//  Created by Dragon on 11/26/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExperienceHeaderView : UICollectionReusableView
{
    ObjectBlock _buttonBlock;
}

@property (nonatomic, strong) IBOutlet UILabel *lblTitle;
@property (nonatomic, strong) IBOutlet UILabel *lblDesc;
@property (nonatomic, strong) IBOutlet UIButton *button;
@property (nonatomic) NSInteger index;

- (void)setTapButtonBlock:(ObjectBlock)block;
@end
