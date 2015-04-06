//
//  DashboardTaskPopup.m
//  Gosu
//
//  Created by Dragon on 10/14/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "DashboardTaskPopup.h"
#import "BlurModalView.h"
#import "NewTaskBaseViewController.h"
#import "StatusBarViewController.h"
#import "TaskIconCell.h"
#import "NSString+Task.h"
#import "DashboardTaskFilterCell.h"

#import "Task+Extra.h"

@interface DashboardTaskPopup()<UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    void (^_completion) ();
}


@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, strong) NSArray *subTaskTypes;
@property (nonatomic, strong) BMVBlurView *blurView;
@property (nonatomic, strong, readonly) UIWindow *overlayWindow;
@property (nonatomic, strong) UIView *screenshot;
@property (nonatomic, strong) NSMutableArray *taskTypes;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIView *draggingItem;
@property (nonatomic, strong) id originalTip;
@end

@implementation DashboardTaskPopup
@synthesize blurView = _blurView;
@synthesize overlayWindow = _overlayWindow;

+ (instancetype)taskPopupWithNavigationController:(UINavigationController *)navVC
{
    DashboardTaskPopup *res = [[DashboardTaskPopup alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
    
    res.navigationController = navVC;
    res.backgroundColor = [UIColor clearColor];
    res.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"DashboardTaskPopup" owner:res options:nil] objectAtIndex:0];
    view.frame = res.bounds;
    [res addSubview:view];
    
    [res.popupTableView registerNib:[UINib nibWithNibName:@"DashboardTaskFilterCell" bundle:nil] forCellReuseIdentifier:@"FilterCell"];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    footerView.backgroundColor = [UIColor clearColor];
    res.popupTableView.tableFooterView = footerView;
    res.subTaskTypes = @[TASK_TYPE_FLIGHT, TASK_TYPE_LIMO, TASK_TYPE_RENTAL, TASK_TYPE_TAXI];
    
    [res.boardCollectionView registerNib:[UINib nibWithNibName:@"TaskEmptyIconCell" bundle:nil] forCellWithReuseIdentifier:@"TaskEmptyIcon"];
    [res.boardCollectionView registerNib:[UINib nibWithNibName:@"TaskIconCell" bundle:nil] forCellWithReuseIdentifier:@"TaskIcon"];
    
    
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:res action:@selector(onPan:)];
    [res.contentView addGestureRecognizer:gesture];
    res.panGesture = gesture;
    
    return res;
}

- (void)setSingleTask:(BOOL)singleTask
{
    _singleTask = singleTask;
    
    if (_singleTask)
        self.mainButton.hidden = YES;
}

#pragma mark Overlay Window

- (UIWindow *)overlayWindow
{
    if(_overlayWindow == nil)
    {
        _overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _overlayWindow.backgroundColor = [UIColor clearColor];
        _overlayWindow.userInteractionEnabled = YES;
        _overlayWindow.windowLevel = UIWindowLevelStatusBar;
        _overlayWindow.rootViewController = [[StatusBarViewController alloc] init];
        _overlayWindow.rootViewController.view.backgroundColor = [UIColor clearColor];
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 7000
        _overlayWindow.rootViewController.wantsFullScreenLayout = YES;
#endif
        [self updateWindowTransform];
        [self updateTopBarFrameWithStatusBarFrame:[[UIApplication sharedApplication] statusBarFrame]];
    }
    
    return _overlayWindow;
}

- (void)updateWindowTransform
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    if (window == nil && [[[UIApplication sharedApplication] windows] count] > 0)
        window = [[UIApplication sharedApplication] windows][0];
    
    _overlayWindow.transform = window.transform;
    _overlayWindow.frame = window.frame;
}

- (void)updateTopBarFrameWithStatusBarFrame:(CGRect)rect
{
    
}

#pragma mark Present/Dismiss

- (void)expandButtons
{
    for (NSInteger i = 0; i < [self.mainButtons count]; i ++)
    {
        CGPoint center = CGPointMake(160, 116);
        center.x += 84 * cos((-180 + i * 45) * M_PI / 180);
        center.y += 84 * sin((-180 + i * 45) * M_PI / 180);
        [self.mainButtons[i] setCenter:center];
    }
}

- (void)collapseButtons
{
    for (NSInteger i = 0; i < [self.mainButtons count]; i ++)
    {
        CGPoint center = CGPointMake(160, 112);
        center.x += 18 * cos((-234 + i * 72) * M_PI / 180);
        center.y += 18 * sin((-234 + i * 72) * M_PI / 180);
        [self.mainButtons[i] setCenter:center];
    }
}

- (void)presentAnimated:(BOOL)animated screenshot:(UIView *)view completion:(void (^)())completion
{
    self.screenshot = view;
    
    _completion = [completion copy];
    
    [self presentAnimated:@(animated)];
}

- (void)presentAnimated:(NSNumber *)animated
{
    
    [self resetBoard];
    
    self.overlayWindow.hidden = NO;
    
    self.frame = self.overlayWindow.rootViewController.view.bounds;
    [self.overlayWindow.rootViewController.view addSubview:self];
    
    if ([animated boolValue])
    {
        self.popupView.alpha = 0;
        
        self.backgroundView.alpha = 0;
        self.contentView.alpha = 0;
        
        [self collapseButtons];
        
        self.blurView = [[BMVBlurView alloc] initWithCoverView:self.screenshot];
        self.blurView.alpha = 0.f;
        [self.overlayWindow.rootViewController.view insertSubview:self.blurView belowSubview:self];
        
        [UIView animateWithDuration:.25 animations:^{
            
            [self expandButtons];
            
            self.contentView.alpha = 1;
            self.backgroundView.alpha = 0.7;
            
            self.blurView.alpha = 1;
            
        } completion:^(BOOL finished) {
            if (_completion) _completion();
            _completion = nil;
        }];
    }
    else
    {
        
        [self expandButtons];
        
        self.popupView.alpha = 0;
        
        self.contentView.alpha = 1;
        self.backgroundView.alpha = 0.7;
        
        self.blurView = [[BMVBlurView alloc] initWithCoverView:self.screenshot];
        [self.overlayWindow.rootViewController.view insertSubview:self.blurView belowSubview:self];
        
        if (_completion) _completion();
        _completion = nil;
    }
    self.screenshot = nil;
}

- (void)dismissAnimated:(BOOL)animated completion:(void (^)())completion
{
    [self dismissWithDuration:animated ? .25 : 0 completion:completion];
}

- (void)dismissWithDuration:(NSTimeInterval)duration completion:(void (^)())completion
{
    
    if ([self.delegate respondsToSelector:@selector(dashboardTaskPopupWillDismiss:)])
    {
        [self.delegate dashboardTaskPopupWillDismiss:self];
    }
    
    [self toggleOffButtons];
    self.popupView.alpha = 0;
    
    [UIView animateWithDuration:duration animations:^{
        
        [self collapseButtons];
        
        self.contentView.alpha = 0;
        self.backgroundView.alpha = 0;
        
        self.blurView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [self.blurView removeFromSuperview];
        [self removeFromSuperview];
        self.blurView = nil;
        
        [self.overlayWindow removeFromSuperview];
        [self.overlayWindow setHidden:YES];
        _overlayWindow.rootViewController = nil;
        _overlayWindow = nil;
        
        if (completion) completion();
        
    }];
}

- (void)dismissWithTypes:(NSArray *)types
{
    
    [self dismissWithDuration:0 completion:^{
        if ([self.delegate respondsToSelector:@selector(dashboardTaskPopup:didDismissWithTypes:)])
        {
            [self.delegate dashboardTaskPopup:self didDismissWithTypes:types];
        }
    }];
}

#pragma mark Main Panel

- (void)resetBoard
{
    self.boardTipLabel.text = @"What can we help you with today?";
    self.taskTypes = [NSMutableArray array];
    [self.boardCollectionView reloadData];
    
}

- (void)updateBoardTipLabel
{
    if ([self.taskTypes count] == 0)
    {
        self.boardTipLabel.text = @"What can we help you with today?";
        return;
    }
    
    id firstObject = [self.taskTypes firstObject];
    id lastObject = [self.taskTypes lastObject];
    lastObject = (lastObject == [NSNull null]) ? [self.taskTypes objectAtIndex:[self.taskTypes count] - 2] : lastObject;
    
    NSString *firstType = firstObject;
    NSString *lastType = lastObject;
    
    if ([self.taskTypes count] == 8 && lastObject != [NSNull null])
    {
        self.boardTipLabel.attributedText = nil;
        self.boardTipLabel.text = @"Please proceed with the tasks.";
    }
    else if ([lastType isEqualToTaskType:TASK_TYPE_TRAVEL ignoreSubType:YES])
    {
        BOOL hadTravel = NO;
        
        for (int i = 0; i < [self.taskTypes count] - 2; i ++)
        {
            id object = self.taskTypes[i];
            
            if ([object isEqualToTaskType:TASK_TYPE_TRAVEL ignoreSubType:YES])
            {
                hadTravel = YES;
                break;
            }
        }
        
        if (hadTravel)
        {
            self.boardTipLabel.attributedText = nil;
            self.boardTipLabel.text = @"Great plan, anything else?";
        }
        else
        {
            NSMutableAttributedString *string = [NSMutableAttributedString new];
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"Would you like to add a " attributes:nil]];
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"Hotel" attributes:@{NSForegroundColorAttributeName:[Task colorForType:TASK_TYPE_ACCOMODATION]}]];
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:@" or " attributes:nil]];
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"Dinner" attributes:@{NSForegroundColorAttributeName:[Task colorForType:TASK_TYPE_FOOD]}]];
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"?" attributes:nil]];
            self.boardTipLabel.attributedText = string;
        }
    }
    else if ([lastType isEqualToTaskType:TASK_TYPE_ACCOMODATION ignoreSubType:YES])
    {
        NSMutableAttributedString *string = [NSMutableAttributedString new];
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"Would you like to add a " attributes:nil]];
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"Dinner" attributes:@{NSForegroundColorAttributeName:[Task colorForType:TASK_TYPE_FOOD]}]];
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"?" attributes:nil]];
        self.boardTipLabel.attributedText = string;
    }
    else if ([lastType isEqualToTaskType:TASK_TYPE_FOOD ignoreSubType:YES])
    {
        NSMutableAttributedString *string = [NSMutableAttributedString new];
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"Great choice, feel like seeing a " attributes:nil]];
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"Show" attributes:@{NSForegroundColorAttributeName:[Task colorForType:TASK_TYPE_ENTERTAINMENT]}]];
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"?" attributes:nil]];
        self.boardTipLabel.attributedText = string;
    }
    else if ([lastType isEqualToTaskType:TASK_TYPE_ENTERTAINMENT ignoreSubType:YES] &&
             [firstType isEqualToTaskType:TASK_TYPE_TRAVEL ignoreSubType:YES])
    {
        NSMutableAttributedString *string = [NSMutableAttributedString new];
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"Will you need a " attributes:nil]];
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:[self.taskTypes firstObject] attributes:@{NSForegroundColorAttributeName:[Task colorForType:TASK_TYPE_TRAVEL]}]];
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:@" home?" attributes:nil]];
        self.boardTipLabel.attributedText = string;
    }
    else
    {
        self.boardTipLabel.attributedText = nil;
        self.boardTipLabel.text = @"Anything else?";
    }
}

- (void)boardAddNewType:(NSString *)type
{
    
    if (self.singleTask) {
        [self dismissWithTypes:@[type]];
        return;
    }
    
    if ([self.taskTypes count] > 8)
        return;
    
    NSArray *typesToAdd = nil;
    
    if ([self.taskTypes count] == 8)
    {
        if ([self.taskTypes lastObject] == [NSNull null])
        {
            typesToAdd = @[type];
        }
        else
        {
            return;
        }
    }
    else
    {
        if ([self.taskTypes count] > 2 && [type isEqualToTaskType:TASK_TYPE_TRAVEL ignoreSubType:YES])
            typesToAdd = @[type];
        else
            typesToAdd = @[type, [NSNull null]];
    }
    
    [self boardAddNewTypes:typesToAdd];	
}

- (void)boardAddNewTypes:(NSArray *)types
{
    
    if ([types count] == 0)
        return;
    
    if ([self.taskTypes lastObject] == [NSNull null])
    {
        
        NSMutableArray *itemsToAdd = [NSMutableArray array];
        
        [self.taskTypes removeLastObject];
        [self.boardCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[self.taskTypes count] inSection:0]]];
        
        for (int i = 0; i < [types count]; i ++)
        {
            [itemsToAdd addObject:[NSIndexPath indexPathForItem:[self.taskTypes count] inSection:0]];
            [self.taskTypes addObject:types[i]];
        }
        
        [self.boardCollectionView insertItemsAtIndexPaths:itemsToAdd];
    }
    else
    {
        NSMutableArray *itemsToAdd = [NSMutableArray array];
        
        for (int i = 0; i < [types count]; i ++)
        {
            [itemsToAdd addObject:[NSIndexPath indexPathForItem:[self.taskTypes count] inSection:0]];
            [self.taskTypes addObject:types[i]];
        }
        
        [self.boardCollectionView insertItemsAtIndexPaths:itemsToAdd];
    }
    
    [self updateBoardTipLabel];
}

- (void)onPan:(UIPanGestureRecognizer *)gesture
{
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            
            UIView *item = nil;
            
            if ([self isSubPopupHidden])
            {
                CGPoint pt = [gesture locationInView:self.boardCollectionView];
                NSIndexPath *indexPath = [self.boardCollectionView indexPathForItemAtPoint:pt];
                
                if (indexPath != nil)
                {
                    id type = self.taskTypes[indexPath.item];
                    if (type != [NSNull null])
                    {
                        
                        TaskIconCell *cell = (TaskIconCell *)[self.boardCollectionView cellForItemAtIndexPath:indexPath];
                        
                        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
                        view.backgroundColor = [UIColor clearColor];
                        item = view;
                        
                        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
                        background.layer.cornerRadius = 25;
                        background.backgroundColor = cell.bgView.backgroundColor;
                        background.layer.shadowOpacity = cell.bgView.layer.shadowOpacity;
                        background.layer.shadowRadius = cell.bgView.layer.shadowRadius;
                        background.layer.shadowOffset = cell.bgView.layer.shadowOffset;
                        [item addSubview:background];
                        
                        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
                        icon.image = cell.iconView.image;
                        icon.contentMode = cell.iconView.contentMode;
                        icon.frame = CGRectMake(5, 5, 50, 50);
                        
                        [item addSubview:icon];
                        
                        item.tag = indexPath.item;
                    }
                }
            }
            
            if (!item)
            {
                gesture.cancelsTouchesInView = YES;
            }
            else
            {
                
                [gesture setTranslation:CGPointZero inView:self.contentView];
                self.draggingItem = item;
                self.originalTip = self.boardTipLabel.attributedText ?: self.boardTipLabel.text;
                self.boardTipLabel.attributedText = nil;
                self.boardTipLabel.text = @"Delete task?";
                
                item.center = [gesture locationInView:self.contentView];
                item.alpha = 0;
                [self.contentView addSubview:item];
                
                [UIView animateWithDuration:.2 animations:^{
                    item.alpha = 1;
                    self.boardCollectionView.alpha = 0;
                    self.buttonView.alpha = 0;
                    self.mainButton.alpha = 0;
                    self.trashButton.alpha = 1;
                }];
                
            }
        }
            
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            if (self.draggingItem)
            {
                CGPoint offset = [gesture translationInView:self.contentView];
                
                CGPoint center = self.draggingItem.center;
                center.x += offset.x;
                center.y += offset.y;
                self.draggingItem.center = center;
                
                [gesture setTranslation:CGPointZero inView:self.contentView];
            }
            
            CGRect itemFrame = self.draggingItem.frame;
            CGRect trashFrame = CGRectInset(self.trashButton.frame, 10, 10);
            
            if (CGRectIntersectsRect(itemFrame, trashFrame))
                self.trashButton.highlighted = YES;
            else
                self.trashButton.highlighted = NO;
            
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            
            if (self.draggingItem)
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.draggingItem.tag inSection:0];
                
                CGRect itemFrame = self.draggingItem.frame;
                CGRect trashFrame = CGRectInset(self.trashButton.frame, 10, 10);
                
                if (CGRectIntersectsRect(itemFrame, trashFrame))
                {
                    
                    if ([self.taskTypes count] == 2 && [self.taskTypes lastObject] == [NSNull null])
                    {
                        [self.taskTypes removeAllObjects];
                    }
                    else
                    {
                        [self.taskTypes removeObjectAtIndex:indexPath.item];
                    }
                    
                    [self.boardCollectionView reloadData];
                    
                    [self updateBoardTipLabel];
                    
                    [UIView animateWithDuration:.25 animations:^{
                        self.draggingItem.alpha = 0;
                        self.boardCollectionView.alpha = 1;
                        self.buttonView.alpha = 1;
                        self.mainButton.alpha = 1;
                        self.trashButton.alpha = 0;
                    } completion:^(BOOL finished) {
                        self.trashButton.highlighted = NO;
                        [self.draggingItem removeFromSuperview];
                        self.draggingItem = nil;
                    }];
                }
                else
                {
                    // move back
                    TaskIconCell *cell = (TaskIconCell *)[self.boardCollectionView cellForItemAtIndexPath:indexPath];
                    CGPoint center = [self.contentView convertPoint:cell.iconView.center fromView:[cell.iconView superview]];
                    if ([self.originalTip isKindOfClass:[NSAttributedString class]])
                        self.boardTipLabel.attributedText = self.originalTip;
                    else
                        self.boardTipLabel.text = self.originalTip;
                    
                    [UIView animateWithDuration:.25 animations:^{
                        self.draggingItem.center = center;
                        self.boardCollectionView.alpha = 1;
                        self.buttonView.alpha = 1;
                        self.mainButton.alpha = 1;
                        self.trashButton.alpha = 0;
                    } completion:^(BOOL finished) {
                        self.trashButton.highlighted = NO;
                        [self.draggingItem removeFromSuperview];
                        self.draggingItem = nil;
                    }];
                }
                
            }
            break;
            
        default:
            break;
    }
}

#pragma mark Internal Buttons

- (void)toggleOffButtons
{
    for (NSInteger i = 0; i < [self.mainButtons count]; i ++)
        [self.mainButtons[i] setSelected:NO];
}

- (IBAction)onDismiss:(id)sender
{
    [self dismissAnimated:YES completion:nil];
}

- (IBAction)onDone:(id)sender
{
    
    if ([self.taskTypes count] == 0)
        return;
    
    NSArray *types;
    if ([self.taskTypes lastObject] == [NSNull null])
        types = [self.taskTypes subarrayWithRange:NSMakeRange(0, [self.taskTypes count] - 1)];
    else
        types = [self.taskTypes copy];
    
    [self dismissWithTypes:types];
}

- (IBAction)onAccomodation:(UIButton *)sender
{
    
    [self toggleOffButtons];
    
    [self dismisSubPopup];
    
    [self boardAddNewType:TASK_TYPE_ACCOMODATION];
}

- (IBAction)onTravel:(UIButton *)sender
{
    
    if (self.btnTravel.selected)
    {
        [self toggleOffButtons];
        [self dismisSubPopup];
        return;
    }
    
    [self toggleOffButtons];
    [self showSubPopupFrom:sender];
}

- (IBAction)onFood:(UIButton *)sender
{
    
    if (sender.selected)
    {
        [self toggleOffButtons];
        [self dismisSubPopup];
        return;
    }
    
    [self toggleOffButtons];
    [self showSubPopupFrom:sender];
}

- (IBAction)onEntertainment:(UIButton *)sender
{
    
    if (self.btnEntertainment.selected)
    {
        [self toggleOffButtons];
        [self dismisSubPopup];
        return;
    }
    
    [self toggleOffButtons];
    [self showSubPopupFrom:self.btnEntertainment];
}

- (IBAction)onGift:(UIButton *)sender
{
    
    [self toggleOffButtons];
    
    [self dismisSubPopup];
    
    [self boardAddNewType:TASK_TYPE_GIFT];
}

#pragma mark Privates


#pragma mark Table View Data Source

- (void) showSubPopupFrom:(UIButton *)sender
{
    
    sender.selected = YES;
    if (sender == self.btnEntertainment)
    {
        self.popupBackgroundView.backgroundColor = [Task colorForType:TASK_TYPE_ENTERTAINMENT];
        self.subTaskTypes = @[TASK_TYPE_SPORTS, TASK_TYPE_THEATRE, TASK_TYPE_CONCERTS, TASK_TYPE_NIGHTLIFE, TASK_TYPE_MOVIE];
    }
    else if (sender == self.btnTravel)
    {
        
        self.popupBackgroundView.backgroundColor = [Task colorForType:TASK_TYPE_TRAVEL];
        self.subTaskTypes = @[TASK_TYPE_FLIGHT, TASK_TYPE_LIMO, TASK_TYPE_RENTAL, TASK_TYPE_TAXI];
    }
    else if (sender == self.btnFood)
    {
        self.popupBackgroundView.backgroundColor = [Task colorForType:TASK_TYPE_FOOD];
        self.subTaskTypes = @[TASK_TYPE_FOOD_TAPAS, TASK_TYPE_FOOD_FUSION, TASK_TYPE_FOOD_HOMESTYLE, TASK_TYPE_FOOD_ETHNIC];
    }
    
    [self.popupTableView reloadData];
    
    UIButton *centerButton = nil;
    if (self.btnAccomodation.center.x == 160)
        centerButton = self.btnAccomodation;
    else if (self.btnTravel.center.x == 160)
        centerButton = self.btnTravel;
    else if (self.btnFood.center.x == 160)
        centerButton = self.btnFood;
    else if (self.btnEntertainment.center.x == 160)
        centerButton = self.btnEntertainment;
    else
        centerButton = self.btnGifts;
    
    CGPoint center = centerButton.center;
    CGPoint origin = sender.center;
    
    [UIView animateWithDuration:.25 animations:^{
        
        if (centerButton != sender)
        {
            centerButton.center = origin;
            sender.center = center;
        }
        
        self.boardView.alpha = 0;
        self.closeButton.alpha = 0;
        self.popupView.alpha = 1;
    }];
}

- (void) dismisSubPopup
{
    if ([self isSubPopupHidden])
        return;
    
    [UIView animateWithDuration:.25 animations:^{
        [self expandButtons];
        self.boardView.alpha = 1;
        self.closeButton.alpha = 1;
        self.popupView.alpha = 0;
    }];
}

- (BOOL) isSubPopupHidden
{
    return self.popupView.alpha == 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.subTaskTypes count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DashboardTaskFilterCell *cell = (DashboardTaskFilterCell *)[tableView dequeueReusableCellWithIdentifier:@"FilterCell"];
    NSString *type = self.subTaskTypes[indexPath.row];
    cell.titleLabel.text = [type uppercaseString];
    
    if (type == TASK_TYPE_FOOD_TAPAS ||
        type == TASK_TYPE_FOOD_FUSION ||
        type == TASK_TYPE_FOOD_HOMESTYLE ||
        type == TASK_TYPE_FOOD_ETHNIC)
        cell.iconView.image = [UIImage imageNamed:@"task_icon_food"];
    else
        cell.iconView.image = [UIImage imageNamed:[NSString stringWithFormat:@"task_icon_%@", [type lowercaseString]]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *type = self.subTaskTypes[indexPath.row];
    
    [self boardAddNewType:type];
    [self toggleOffButtons];
    [self dismisSubPopup];
}

#pragma mark Board CollecitonView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.taskTypes count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id object = self.taskTypes[indexPath.item];
    
    if (object == [NSNull null])
        return CGSizeMake(60, 60);
    
    return CGSizeMake(75, 60);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell *res = nil;
    
    id object = self.taskTypes[indexPath.item];
    
    if (object == [NSNull null])
    {
        res = [collectionView dequeueReusableCellWithReuseIdentifier:@"TaskEmptyIcon" forIndexPath:indexPath];
    }
    else
    {
        NSString *taskType = object;
        
        TaskIconCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TaskIcon" forIndexPath:indexPath];
        
        cell.bgView.backgroundColor = [Task colorForType:taskType];
        
        if (taskType == TASK_TYPE_FOOD_TAPAS ||
           taskType == TASK_TYPE_FOOD_FUSION ||
           taskType == TASK_TYPE_FOOD_HOMESTYLE ||
           taskType == TASK_TYPE_FOOD_ETHNIC)
            cell.iconView.image = [UIImage imageNamed:@"task_icon_food"];
        else
            cell.iconView.image = [UIImage imageNamed:[NSString stringWithFormat:@"task_icon_%@", [taskType lowercaseString]]];
        
        res = cell;
    }
    
    return res;
}

@end

@implementation DashboardTaskSubPopup

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CAShapeLayer *maskLayer = (CAShapeLayer *)self.layer.mask;
    
    if (!self.layer.mask)
    {
        maskLayer = [CAShapeLayer new];
        self.layer.mask = maskLayer;
    }
    
    CGFloat arrowH = 10, arrowW = 20;
    CGSize size = self.bounds.size;
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointZero];
    [path addLineToPoint:CGPointMake(0, size.height - arrowH)];
    [path addLineToPoint:CGPointMake(size.width * 0.5 - arrowW * 0.5, size.height - arrowH)];
    [path addLineToPoint:CGPointMake(size.width * 0.5, size.height)];
    [path addLineToPoint:CGPointMake(size.width * 0.5 + arrowW * 0.5, size.height - arrowH)];
    [path addLineToPoint:CGPointMake(size.width, size.height - arrowH)];
    [path addLineToPoint:CGPointMake(size.width, 0)];
    [path closePath];
    
    maskLayer.path = path.CGPath;
    
}

@end
