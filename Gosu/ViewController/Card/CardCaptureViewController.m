//
//  CardCaptureViewController.m
//  Gosu
//
//  Created by dragon on 3/21/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "CardCaptureViewController.h"

@interface CardCaptureViewController ()

@end

@implementation CardCaptureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    DLog(@"CardCaptureViewController deallocated");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.cardIOView.delegate = self;
    self.cardIOView.appToken = kCardIOAppTocken;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Actions

- (IBAction)onBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Card Capture Delegate
- (void)cardIOView:(CardIOView *)cardIOView didScanCard:(CardIOCreditCardInfo *)cardInfo
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardCaptureViewController:didScanCard:)])
        [self.delegate cardCaptureViewController:self didScanCard:cardInfo];
    else
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
