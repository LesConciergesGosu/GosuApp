//
//  CardListViewController.m
//  Gosu
//
//  Created by dragon on 3/29/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "CardListViewController.h"
#import "CardInputViewController.h"
#import "UIViewController+ViewDeck.h"
#import "CreditCard+Extra.h"
#import "User+Extra.h"
#import "PCreditCard.h"

#import <SVProgressHUD/SVProgressHUD.h>


@interface CardListViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    BOOL viewDidLoad_;
}
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIBarButtonItem *editbutton;
@property (nonatomic, strong) NSMutableArray *cards;
@property (nonatomic, strong) NSMutableArray *removedCards;
@property (nonatomic, strong) CreditCard *defaultCard;
@end

@implementation CardListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)] ) {
        [self.navigationController interactivePopGestureRecognizer].enabled = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView:) name:NotificationCardAdded object:nil];
    
    viewDidLoad_ = NO;
    
    [self reloadTableView:nil];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!viewDidLoad_) {
        
        self.title = @"Payment";
        
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onEdit:)];
        self.navigationItem.rightBarButtonItem = editButton;
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone:)];
        
        self.editbutton = editButton;
        self.doneButton = doneButton;
        
        [self.tableView reloadData];
        
        viewDidLoad_ = YES;
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.tableView isEditing]) {
        [self.navigationItem setRightBarButtonItem:self.editbutton animated:NO];
        [self.tableView setEditing:NO animated:NO];
        [self reloadTableView:nil];
    }
}

#pragma mark Actions

- (void)onEdit:(id)sender {
    [self.navigationItem setRightBarButtonItem:self.doneButton animated:YES];
    [self.tableView setEditing:YES animated:YES];
}

- (void)onDone:(id)sender {
    [self.navigationItem setRightBarButtonItem:self.editbutton animated:YES];
    [self.tableView setEditing:NO animated:YES];
    
    if ([self.removedCards count] > 0) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        __weak typeof (self) wself = self;
        [[User currentUser] removeCards:self.removedCards CompletionHandler:^(BOOL success, NSString *errorDesc) {
            [SVProgressHUD dismiss];
            CardListViewController *sself = wself;
            if (!sself)
                return;
            
            [sself reloadTableView:nil];
        }];
    }
}

#pragma mark Card Add Notification

- (void) reloadTableView:(id)sender {
    User *currentUser = [User currentUser];
    self.cards = [NSMutableArray arrayWithArray:[currentUser.cards array]];
    self.removedCards = [NSMutableArray array];
    self.defaultCard = currentUser.defaultCard;
    [self.tableView reloadData];
}


#pragma mark table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.cards count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *normalCellIdentifier = @"normalCardCell";
    static NSString *selectedCellIdentifier = @"selectedCardCell";
    
    NSString *cellIdentifier = normalCellIdentifier;
    
    CreditCard *card = self.cards[indexPath.row];
    if (card == self.defaultCard)
        cellIdentifier = selectedCellIdentifier;
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.imageView.image = [card cardLogo];
    cell.detailTextLabel.text = [card redactedCardNumber];
    cell.textLabel.text = [card displayTypeString];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        CreditCard *card = self.cards[indexPath.row];
        [self.removedCards addObject:card];
        [self.cards removeObject:card];
        
        if (card == self.defaultCard) {
            self.defaultCard = [self.cards count] > 0 ? self.cards[0] : nil;
        }
        [self.tableView reloadData];
    }
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CreditCard *card = self.cards[indexPath.row];
    if (card != [User currentUser].defaultCard) {
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        __weak typeof (self) wself = self;
        [[User currentUser] setDefaultCard:card CompletionHandler:^(BOOL success, NSString *errorDesc) {
            [SVProgressHUD dismiss];
            CardListViewController *sself = wself;
            if (sself) {
                [sself reloadTableView:nil];
            }
        }];
    }
}

@end
