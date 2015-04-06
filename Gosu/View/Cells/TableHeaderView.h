//
//  TableHeaderView.h
//  mBrace
//
//  Created by dragon on 5/12/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TableHeaderView;
@protocol TableHeaderViewDelegate <NSObject>

- (void) onTapHeaderViewDisclosure:(TableHeaderView *)headerView;

@end

@interface TableHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *detailLabel;
@property (nonatomic, strong) IBOutlet UIButton *disclosureButton;

@property (weak) id<TableHeaderViewDelegate> delegate;
@property (nonatomic) NSInteger section;

- (IBAction) onDisclosure:(id)sender;
@end
