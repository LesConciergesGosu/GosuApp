//
//  DashboardTaskPopup.h
//  Gosu
//
//  Created by Dragon on 10/14/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DashboardTaskPopup;
@protocol DashboardTaskPopupDelegate <NSObject>

@optional
- (void)dashboardTaskPopup:(DashboardTaskPopup *)popup didDismissWithTypes:(NSArray *)types;
- (void)dashboardTaskPopupWillDismiss:(DashboardTaskPopup *)popup;

@end

@class DashboardTaskSubPopup;
@interface DashboardTaskPopup : UIView

@property (nonatomic, strong) IBOutlet UIView *backgroundView;

@property (nonatomic, strong) IBOutlet UIButton *closeButton;
@property (nonatomic, strong) IBOutlet UIButton *mainButton;

@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, strong) IBOutlet UIButton *trashButton;

@property (nonatomic, strong) IBOutlet UIView *boardView;
@property (nonatomic, strong) IBOutlet UILabel *boardTipLabel;
@property (nonatomic, strong) IBOutlet UICollectionView *boardCollectionView;
@property (nonatomic, strong) NSMutableArray *boardButtons;

@property (nonatomic, strong) IBOutlet DashboardTaskSubPopup *popupView;
@property (nonatomic, strong) IBOutlet UIView *popupBackgroundView;
@property (nonatomic, strong) IBOutlet UITableView *popupTableView;

@property (nonatomic, strong) IBOutlet UIView *buttonView;
@property (nonatomic, weak) IBOutlet UIButton *btnAccomodation;
@property (nonatomic, weak) IBOutlet UIButton *btnTravel;
@property (nonatomic, weak) IBOutlet UIButton *btnFood;
@property (nonatomic, weak) IBOutlet UIButton *btnEntertainment;
@property (nonatomic, weak) IBOutlet UIButton *btnGifts;

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *mainButtons;

@property (nonatomic, weak) id<DashboardTaskPopupDelegate> delegate;
@property (nonatomic) BOOL singleTask;

+ (instancetype)taskPopupWithNavigationController:(UINavigationController *)navVC;
- (void)presentAnimated:(BOOL)animated screenshot:(UIView *)view completion:(void (^)())completion;
- (void)dismissAnimated:(BOOL)animated completion:(void (^)())completion;
@end




@interface DashboardTaskSubPopup : UIView

@end