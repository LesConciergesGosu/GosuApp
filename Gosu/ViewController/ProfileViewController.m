//
//  ProfileViewController.m
//  Gosu
//
//  Created by dragon on 3/23/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "ProfileViewController.h"
#import "UIViewController+ViewDeck.h"
#import "TableHeaderView.h"
#import "TableFooterView.h"

#import "ProfileCardCell.h"
#import "ProfileInformationCell.h"
#import "ProfileFamilyCell.h"
#import "ProfileFavoritePickerCell.h"
#import "ProfileGosuCell.h"
#import "ProfileHeaderCell.h"
#import "ButtonCell.h"

#import "CardHelper.h"

#import "FieldInputViewController.h"
#import "GeneralInfomationAddViewController.h"
#import "ProfileEditViewController.h"
#import "CardInputViewController.h"
#import "NSDictionary+Profile.h"
#import "User+Extra.h"
#import "UserProfile+Extra.h"
#import "CreditCard+Extra.h"
#import "DataManager.h"
#import "PUserProfile.h"
#import <UIImage-Categories/UIImage+Resize.h>

typedef NS_ENUM(NSInteger, ProfileSection) {
    ProfileSectionInformation,
    ProfileSectionFamilyFriends,
    ProfileSectionGosu,
    ProfileSectionPayment,
    ProfileSectionFavorite,
    ProfileSectionCalendar,
    ProfileSectionCount
};

typedef NS_ENUM(NSInteger, ProfileViewMode) {
    ProfileViewModeView,
    ProfileViewModeEdit
};

typedef NS_ENUM(NSInteger, ProfileChangeFlag) {
    ProfileChangeFlagNone,
    ProfileChangeFlagMainProfile,
    ProfileChangeFlagGeneralInformation,
    ProfileChangeFlagFamilyFriends,
    ProfileChangeFlagGosu,
    ProfileChangeFlagPayment,
    ProfileChangeFlagFavorite
};

@class CreditCard;
@interface ProfileViewController ()
<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate,
UITableViewDelegate, UITableViewDataSource, TableHeaderViewDelegate, ButtonCellDelegate,
ProfileFavoritePickerCellDelegate,ProfileGosuCellDelegate, RemovableCellDelegate,
FieldInputViewControllerDelgate, GeneralInfomationAddViewControllerDelegate>
{
    BOOL viewLoaded_;
    NSInteger changed_;
    UIBackgroundTaskIdentifier backgroundTask;
}

@property (nonatomic, strong) NSMutableArray *family;
@property (nonatomic, strong) NSMutableArray *favorites;
@property (nonatomic, strong) NSMutableArray *general;
@property (nonatomic, strong) NSMutableArray *cards;
@property (nonatomic, strong) NSMutableArray *gosues;

@property (nonatomic, strong) CreditCard *defaultCard;
@property (nonatomic) BOOL editable;
@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)] ) {
        [self.navigationController interactivePopGestureRecognizer].enabled = NO;
    }
    
    self.title = @"Profile";
    [self.tableView registerNib:[UINib nibWithNibName:@"TableHeaderView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"profileSectionHeader"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TableFooterView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"profileSectionFooter"];
    
    changed_ = ProfileChangeFlagNone;
    viewLoaded_ = NO;
    
//    self.editable = [self currentUser] == [User currentUser];
    self.editable = self.user == nil;
    if ([self editable]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadCardList:)
                                                     name:NotificationCardAdded
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        self.fullNameButton.hidden = NO;
    } else {
        self.fullNameButton.hidden = YES;
    }
}

- (void)applicationWillResignActive:(id)sender
{
    [self saveChangesIfNeeded];
}

- (void)applicationDidBecomeActive:(id)sender
{
    if (backgroundTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.navigationController.viewControllers count] <= 1)
        [self saveChangesIfNeeded];
}

- (void) viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    if (!viewLoaded_) {
        
        if (self.user != nil)
            self.navigationItem.leftBarButtonItem = nil;
        
        [self setupData];
        viewLoaded_ = YES;
    } else {
        [self loadBaseProfile];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (User *)currentUser
{
    return self.user ? self.user : [User currentUser];
}

#pragma mark Editing

- (void) saveChangesIfNeeded
{
    if ([self editable] && changed_ > ProfileChangeFlagNone) {
        
        backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            if (backgroundTask != UIBackgroundTaskInvalid)
                [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
            backgroundTask = UIBackgroundTaskInvalid;
        }];
        
        __weak ProfileViewController *wself = self;
        [self saveProfileChangesWithCompletion:^(BOOL success, NSString *errorDesc) {
            
            DLog(@"saved the profile with error : \n%@", errorDesc);
            
            __strong ProfileViewController *sself = wself;
            
            if (sself) {
                if (success)
                    changed_ = ProfileChangeFlagNone;
                
                if (backgroundTask == UIBackgroundTaskInvalid) {
                    [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
                    backgroundTask = UIBackgroundTaskInvalid;
                }
            }
        }];
    }
}

- (void) saveProfileChangesWithCompletion:(GSuccessWithErrorBlock)block
{
    User *user = [self currentUser];
    
    if (user != [User currentUser]) {
        block(NO, @"Cannot change other's profile.");
        return;
    }
    
    // save profile in local database
    PUserProfile *pProfile = nil;
    
    if (user.profile) {
        
        UserProfile *profile = user.profile;
        
        profile.family = self.family;
        profile.favorites = self.favorites;
        profile.general = self.general;
        
        [[DataManager manager] saveMainContext];
        
        pProfile = [PUserProfile objectWithoutDataWithObjectId:profile.objectId];
        
    } else {
        
        pProfile = [PUserProfile object];
        
    }
    
    // save profile in remote database
    pProfile.family = self.family;
    pProfile.favorites = self.favorites;
    pProfile.general = self.general;
    
    __weak ProfileViewController *wself = self;
    [user saveProfile:pProfile completionHandler:^(BOOL success, NSString *errorDesc) {
        ProfileViewController *sself = wself;
        
        if (sself) {
            
            block (success, errorDesc);
        }
    }];
}

- (void) setupData
{
    
    User *user = [self currentUser];
    
    // load profile
    self.family = [NSMutableArray arrayWithArray:user.profile.family];
    self.favorites = [NSMutableArray arrayWithArray:user.profile.favorites];
    self.general = [NSMutableArray arrayWithArray:user.profile.general];
    
    if ([user.profile.dataAvailable  boolValue])
    {
        [self loadHeaderView];
    }
    
//    if (!reset)
    {
        __weak ProfileViewController *wself = self;
        
        GSuccessWithErrorBlock block = ^(BOOL success, NSString *errorDesc) {
            
            __strong ProfileViewController *sself = wself;
            
            if (sself && success) {
                
                [sself loadHeaderView];
            }
            
        };
        
        if (user == [User currentUser])
            [user refreshProfileWithCompletionHandler:block];
        else
            [user pullProfileWithCompletionHandler:block];
    }
    
    // load gosu list
    self.gosues = [[user gosuRelations] mutableCopy];
    
    {
        __weak ProfileViewController *wself = self;
        [user pullGosuListWithCompletionHandler:^(BOOL success, NSString *errorDesc) {
            [[DataManager manager] refreshTaskQueues];
            __strong ProfileViewController *sself = wself;
            
            if (sself && success) {
                sself.gosues = [[[sself currentUser] gosuRelations] mutableCopy];
                [sself.tableView reloadData];
            }
        }];
    }
    
    // load card list
    [self reloadCardList:nil];
    
    // load user name & photo
    [self loadBaseProfile];
}

- (void) loadBaseProfile
{
    User *user = [self currentUser];
    
    // load user name
    [self fullNameLabel].text = [user fullName];
    
    // load photo
    
    if (user.photo) {
        
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:user.photo]];
        
        __weak ProfileViewController *wself = self;
        [[DataManager manager] loadImageURLRequest:request handler:^(UIImage *image) {
            
            ProfileViewController *sself = wself;
            
            if (!sself)
                return;
            
            if (image) {
                [sself.photoImageView setImage:image];
            } else {
                [sself.photoImageView setImage:[UIImage imageNamed:@"buddy.png"]];
            }
        }];
        
    } else {
        [self.photoImageView setImage:[UIImage imageNamed:@"buddy.png"]];
    }
}

- (void) loadHeaderView
{
    User *user = [self currentUser];
    
    int countOfCompletedTasks = 0;
    int countOfOngoingTasks = 0;
    int savedHours = 0;
    
    if (user.profile) {
        countOfCompletedTasks = [user.profile.countOfCompletedTasks intValue];
        countOfOngoingTasks = [user.profile.countOfOngoingTasks intValue];
        savedHours = [user.profile.savedHours intValue];
    }
    
    NSDictionary *greenAttr = @{UITextAttributeTextColor:APP_COLOR_GREEN};
    NSDictionary *grayAttr = @{UITextAttributeTextColor:APP_COLOR_TEXT_GRAY};
    
    NSString *string;
    NSMutableAttributedString *attrString;
    
    string = [NSString stringWithFormat:@"%d completed tasks", countOfCompletedTasks];
    attrString = [[NSMutableAttributedString alloc] initWithString:string attributes:grayAttr];
    [attrString addAttributes:greenAttr range:NSMakeRange(0, [string rangeOfString:@" "].location)];
    
    self.lblCountOfCompletedTasks.attributedText = attrString;
    
    string = [NSString stringWithFormat:@"%d ongoing tasks", countOfOngoingTasks];
    attrString = [[NSMutableAttributedString alloc] initWithString:string attributes:grayAttr];
    [attrString addAttributes:greenAttr range:NSMakeRange(0, [string rangeOfString:@" "].location)];
    
    self.lblCountOfOngoingTasks.attributedText = attrString;
    
    string = [NSString stringWithFormat:@"%d hours saved", savedHours];
    attrString = [[NSMutableAttributedString alloc] initWithString:string attributes:greenAttr];
    
    self.lblSavedHours.attributedText = attrString;
    
    self.family = [NSMutableArray arrayWithArray:user.profile.family];
    self.favorites = [NSMutableArray arrayWithArray:user.profile.favorites];
    self.general = [NSMutableArray arrayWithArray:user.profile.general];
    
    [self.tableView reloadData];
}


#pragma mark Delegates

- (BOOL)shouldRemoveableCellRemoved:(RemovableCell *)pCell
{
    id data = pCell.data;
    NSInteger index;
    NSIndexPath *indexPath;
    
    BOOL res = YES;
    
    switch (pCell.indexPath.section) {
        case ProfileSectionInformation:
        {
            index = [self.general indexOfObject:data];
            
            if (index != NSNotFound) {
                indexPath = [NSIndexPath indexPathForItem:index inSection:ProfileSectionInformation];
                [self.general removeObjectAtIndex:index];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                changed_ |= ProfileChangeFlagGeneralInformation;
            } else {
                res = NO;
            }
        }
            break;
        case ProfileSectionFamilyFriends:
        {
            index = [self.family indexOfObject:data];
            
            if (index != NSNotFound) {
                indexPath = [NSIndexPath indexPathForItem:index inSection:ProfileSectionFamilyFriends];
                [self.family removeObjectAtIndex:index];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                changed_ |= ProfileChangeFlagFamilyFriends;
            } else {
                res = NO;
            }
        }
            break;
        case ProfileSectionPayment:
        {
            index = [self.cards indexOfObject:data];
            
            if (index != NSNotFound) {
                indexPath = [NSIndexPath indexPathForItem:index inSection:ProfileSectionPayment];
                
                [[self currentUser] removeCard:data CompletionHandler:^(BOOL success, NSString *errorDesc) {
                    
                }];
                
                [self.cards removeObjectAtIndex:index];
                
                if (data == self.defaultCard) {
                    
                    self.defaultCard = [self.cards count] > 0 ? self.cards[0] : nil;
                    [self.tableView beginUpdates];
                    [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                          withRowAnimation:UITableViewRowAnimationRight];
                    [self.tableView endUpdates];
                    
                } else {
                    
                    [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                          withRowAnimation:UITableViewRowAnimationRight];
                }
                
            } else {
                res = NO;
            }
        }
            break;
        case ProfileSectionFavorite:
        {
            index = [self.favorites indexOfObject:data];
            
            if (index != NSNotFound) {
                indexPath = [NSIndexPath indexPathForItem:index + 1 inSection:ProfileSectionFavorite];
                [self.favorites removeObjectAtIndex:index];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                changed_ |= ProfileChangeFlagFavorite;
            } else {
                res = NO;
            }
        }
            break;
        default:
            res = NO;
    }
    
    return res;
}

- (void) onTapHeaderViewDisclosure:(TableHeaderView *)headerView
{
    
}

- (void) buttonCellButtonTapped:(ButtonCell *)cell
{
    if (cell.indexPath.section == ProfileSectionInformation) {
        
        GeneralInfomationAddViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GeneralInfomationAddViewController"];
        
        NSMutableArray *availableTypes = [[GeneralInfomationAddViewController availableInformationTypes] mutableCopy];
        for (NSDictionary *generalInformation in self.general) {
            [availableTypes removeObject:generalInformation[@"type"]];
        }
        vc.availableTypes = availableTypes;
        vc.delegate = self;
        
        [self.navigationController pushViewController:vc animated:YES];
        
    } else if (cell.indexPath.section == ProfileSectionPayment) {
        
        CardInputViewController *cardInputVC = [self.storyboard instantiateViewControllerWithIdentifier:@"cardInputViewController"];
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:cardInputVC];
        navVC.navigationBar.translucent = NO;
        
        [self.navigationController presentViewController:navVC animated:YES completion:nil];
        
    } else if (cell.indexPath.section == ProfileSectionFamilyFriends) {
        
        FieldInputViewController *fieldInputVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FieldInputViewController"];
        
        NSArray *inputFields = @[@{@"title": @"Relationship :",
                                   @"type": @(FieldInputValueTypeString),
                                   @"default": @"Mom",
                                   @"method":@(FieldInputMethodPicker),
                                   @"values":@[@"Mom", @"Dad", @"Brother", @"Sister", @"Family Person", @"Friend"]},
                                 @{@"title": @"Name :",
                                   @"type": @(FieldInputValueTypeString),
                                   @"keyboard": @(UIKeyboardTypeDefault),
                                   @"default": @"",
                                   @"method":@(FieldInputMethodText)},
                                 @{@"title": @"Address :",
                                   @"type": @(FieldInputValueTypeString),
                                   @"keyboard": @(UIKeyboardTypeDefault),
                                   @"default": @"",
                                   @"method":@(FieldInputMethodText)}];
        
        fieldInputVC.inputFields = inputFields;
        fieldInputVC.tag = ProfileSectionFamilyFriends;
        fieldInputVC.delegate = self;
        
        [self.navigationController pushViewController:fieldInputVC animated:YES];
    }
}

- (void) profileFavoritePickerCell:(ProfileFavoritePickerCell *)cell pickCategory:(NSString *)category withItem:(NSString *)item
{
    // skip the item added already.
    for (NSDictionary *favorite in self.favorites) {
        if ([favorite[@"category"] isEqualToString:category] &&
            [favorite[@"item"] isEqualToString:item]) {
            return;
        }
    }
    
    // add the item
    NSDictionary *favorite = @{@"category":category, @"item":item};
    [self.favorites addObject:favorite];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.favorites count] inSection:ProfileSectionFavorite]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    
    changed_ |= ProfileChangeFlagFavorite;
}

- (void) profileGosuCellRemove:(ProfileGosuCell *)cell
{
    NSInteger index = cell.indexPath.row;
    if (index < [self.gosues count]) {
        
        [[self currentUser] removeGosuRelation:self.gosues[index] completionHandler:^(BOOL success, NSString *errorDesc) {
            DLog(@"removed a gosu relation from the server");
        }];
        
        [self.gosues removeObjectAtIndex:index];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:ProfileSectionGosu]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
//        changed_ |= ProfileChangeFlagGosu;
    }
}

#pragma mark Credit Card Management

- (void) reloadCardList:(id)sender {
    self.cards = [NSMutableArray arrayWithArray:[[self currentUser].cards array]];
    self.defaultCard = [self currentUser].defaultCard;
    [self.tableView reloadData];
}

#pragma mark Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return ProfileSectionCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section != ProfileSectionCalendar)
        return 50;
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == ProfileSectionCalendar)
        return nil;
    
    TableHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"profileSectionHeader"];
    
    switch (section) {
            
        case ProfileSectionInformation:
            headerView.titleLabel.text = @"Additional Information";
            headerView.disclosureButton.hidden = YES;
            break;
            
        case ProfileSectionFamilyFriends:
            headerView.titleLabel.text = @"Family and Friends";
//            headerView.disclosureButton.hidden = NO;
            headerView.section = section;
            headerView.delegate = self;
            break;
            
        case ProfileSectionGosu:
            headerView.titleLabel.text = @"Gosu";
            headerView.disclosureButton.hidden = YES;
            break;
            
        case ProfileSectionPayment:
            headerView.titleLabel.text = @"Payment";
            headerView.disclosureButton.hidden = YES;
            break;
            
        case ProfileSectionFavorite:
            headerView.titleLabel.text = @"Favorites";
            headerView.disclosureButton.hidden = YES;
            
        default:
            break;
    }
    
    if (!headerView.backgroundView) {
        headerView.backgroundView = [[UIView alloc] initWithFrame:headerView.bounds];
        headerView.backgroundView.backgroundColor = APP_COLOR_BACKGROUND;
    }
    
    
    return headerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section != ProfileSectionCalendar && [self tableView:tableView numberOfRowsInSection:section] > 0)
        return 5;
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (section == ProfileSectionCalendar)
        return nil;
    else {
        
        TableFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"profileSectionFooter"];
        
        if (!footerView.backgroundView) {
            footerView.backgroundView = [[UIView alloc] initWithFrame:footerView.bounds];
            footerView.backgroundView.backgroundColor = APP_COLOR_BACKGROUND;
        }
        
        return footerView;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger res = 0;
    switch (section) {
            
        case ProfileSectionInformation:
            res = [self editable] ? [self.general count] + 1 : [self.general count];
            break;
            
        case ProfileSectionFamilyFriends:
            res = [self editable] ? [self.family count] + 1 : [self.family count];
            break;
            
        case ProfileSectionGosu:
            res = [self.gosues count];
            break;
            
        case ProfileSectionPayment:
            res = [self editable] ? [self.cards count] + 1 : [self.cards count];
            break;
            
        case ProfileSectionFavorite:
            res = [self editable] ? [self.favorites count] + 1 : [self.favorites count];
            break;
            
        case ProfileSectionCalendar:
            res = 1;
            break;
            
        default:
            break;
    }
    
    return res;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat res = 0;
    
    switch (indexPath.section) {
            
        case ProfileSectionInformation:
            if (indexPath.row < [self.general count]) {
                NSDictionary *info = self.general[indexPath.row];
                res = [ProfileInformationCell heightForDetailText:info[@"desc"] withTitle:info[@"title"]];
            }
            else
                res = 40;
            break;
        case ProfileSectionFamilyFriends:
            if (indexPath.row < [self.family count])
                res = 90;
            else
                res = 40;
            break;
        case ProfileSectionGosu:
            res = 50;
            break;
        case ProfileSectionPayment:
            if (indexPath.row < [self.cards count])
                res = 35;
            else
                res = 40;
            break;
        case ProfileSectionFavorite:
            if (indexPath.row == 0 && [self editable])
                res = 200;
            else
                res = 35;
            break;
        case ProfileSectionCalendar:
            res = 50;
            break;
        default:
            res = 40;
            break;
    }
    
    return res;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *res = nil;
    
    switch (indexPath.section) {
            
        case ProfileSectionInformation:
        {
            if (indexPath.row < [self.general count]) {
                NSDictionary *info = self.general[indexPath.row];
                ProfileInformationCell *cell =
                [tableView dequeueReusableCellWithIdentifier:@"ProfileInformationCell"];
                cell.titleLabel.text = info[@"title"];
                cell.detailLabel.text = info[@"desc"];
                cell.swipeToDeleteEnabled = [self editable];
                cell.indexPath = indexPath;
                cell.data = info;
                cell.delegate = self;
                [cell resizeToFit];
                res = cell;
            } else {
                ButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileAddCell"];
                cell.indexPath = indexPath;
                cell.delegate = self;
                res = cell;
            }
            
        }
            break;
            
        case ProfileSectionFamilyFriends:
        {
            if (indexPath.row < [self.family count]) {
                NSDictionary *familyInfo = self.family[indexPath.row];
                ProfileFamilyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileFamilyCell"];
                cell.lblRelation.text = familyInfo[@"relation"];
                cell.lblName.text = familyInfo[@"name"];
                cell.lblAddress.text = familyInfo[@"address"];
                cell.swipeToDeleteEnabled = [self editable];
                cell.indexPath = indexPath;
                cell.data = familyInfo;
                cell.delegate = self;
                res = cell;
            } else {
                ButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileAddCell"];
                cell.indexPath = indexPath;
                cell.delegate = self;
                res = cell;
            }
            
            break;
        }
            
        case ProfileSectionGosu:
        {
            ProfileGosuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileGosuCell"];
            [cell setData:self.gosues[indexPath.row]];
            cell.indexPath = indexPath;
            cell.delegate = self;
            cell.removeButton.hidden = ![self editable];
            res = cell;
        }
            break;
            
        case ProfileSectionPayment:
        {
            if (indexPath.row < [self.cards count]) {
                ProfileCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCardCell"];
                
                CreditCard *card = self.cards[indexPath.row];
                
                CardIOCreditCardType ccType = [CardHelper ccType:card.cardNumber];
                
                NSString *type = @"Unknown";
                switch (ccType) {
                    case CardIOCreditCardTypeAmex:
                        type = @"American Express";
                        break;
                    case CardIOCreditCardTypeJCB:
                        type = @"JCB";
                        break;
                    case CardIOCreditCardTypeMastercard:
                        type = @"MasterCard";
                        break;
                    case CardIOCreditCardTypeDiscover:
                        type = @"Discover";
                        
                    case CardIOCreditCardTypeVisa:
                        type = @"Visa";
                        break;
                        
                    default:
                        break;
                }
                
                NSString *title = [type stringByAppendingString:@":"];
                
                NSString *text = [NSString stringWithFormat:@"%@ %@", title, [CardHelper redactedCardNumberFor:card.cardNumber hasSpace:YES]];
                NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:text attributes:@{UITextAttributeFont:[UIFont systemFontOfSize:14], UITextAttributeTextColor:APP_COLOR_TEXT_GRAY}];
                [str setAttributes:@{UITextAttributeTextColor:APP_COLOR_GREEN} range:[text rangeOfString:title]];
                cell.titleLabel.attributedText = str;
                cell.selectionIndicator.hidden = !(card == self.defaultCard);
                cell.selectionStyle = [self editable] ? UITableViewCellSelectionStyleBlue : UITableViewCellEditingStyleNone;
                cell.swipeToDeleteEnabled = [self editable];
                cell.indexPath = indexPath;
                cell.delegate = self;
                cell.data = card;
                res = cell;
                
            } else {
                ButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileAddCell"];
                cell.indexPath = indexPath;
                cell.delegate = self;
                res = cell;
            }
            
        }
            break;
            
        case ProfileSectionFavorite:
        {
            
            if ([self editable] && indexPath.row == 0) {
                
                ProfileFavoritePickerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileFavoritesPickerCell"];
                cell.delegate = self;
                
                res = cell;
            } else if (indexPath.row <= [self.favorites count]){
                
                NSInteger index = [self editable] ? indexPath.row - 1 : indexPath.row;
                
                NSDictionary *info = self.favorites[index];
                ProfileInformationCell *cell =
                [tableView dequeueReusableCellWithIdentifier:@"ProfileFavoriteCell"];
                cell.titleLabel.text = [info[@"category"] stringByAppendingString:@":"];
                cell.detailLabel.text = info[@"item"];
                cell.swipeToDeleteEnabled = [self editable];
                cell.indexPath = indexPath;
                cell.data = info;
                cell.delegate = self;
                res = cell;
            }
        }
            break;
            
        case ProfileSectionCalendar:
        {
            ButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCalenarCell"];
            cell.indexPath = indexPath;
            cell.delegate = self;
            res = cell;
            
        }
            break;
            
        default:
            break;
    }
    
    if (res) {
        res.contentView.backgroundColor = APP_COLOR_BACKGROUND;
    }
    
    
    return res;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (![self editable])
        return;
    
    if (indexPath.section == ProfileSectionPayment && indexPath.row < [self.cards count])
    {
        CreditCard *card = self.cards[indexPath.row];
        if (card != self.defaultCard) {
            self.defaultCard = card;
            [self.tableView reloadData];
        }
    }
}

#pragma mark FieldInputViewControllerDelegate
- (void)fieldInputViewController:(FieldInputViewController *)vc didFinishWithResults:(NSArray *)results {
    
    if (vc.tag == ProfileSectionFamilyFriends) {
        NSDictionary *family = @{@"relation":[results[0] objectForKey:@"value"],
                                 @"name":[results[1] objectForKey:@"value"],
                                 @"address":[results[2] objectForKey:@"value"]};
        [self.family addObject:family];
        [self.tableView reloadData];
        
        changed_ |= ProfileChangeFlagFamilyFriends;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark GeneralInformationAddViewControllerDelegate
- (void)generalInformationAddViewController:(GeneralInfomationAddViewController *)vc didFinishWithResult:(NSDictionary *)result
{
    if (vc.data == nil) {
        
        // add new general information
        
        NSMutableDictionary *newInfo = [result mutableCopy];
        newInfo[@"desc"] = [newInfo generalProfileDescription];
        [self.general addObject:newInfo];
        [self.tableView reloadData];
        
        changed_ |= ProfileChangeFlagGeneralInformation;
        
    } else {
        
        // edit the existing general information
        
        NSIndexPath *indexPath = (NSIndexPath *)vc.data;
        
        NSMutableDictionary *changedInfo = [result mutableCopy];
        changedInfo[@"desc"] = [changedInfo generalProfileDescription];
        [self.general replaceObjectAtIndex:indexPath.row withObject:changedInfo];
        [self.tableView reloadData];
        
        changed_ |= ProfileChangeFlagGeneralInformation;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
