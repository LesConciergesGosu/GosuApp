//
//  CardCaptureViewController.h
//  Gosu
//
//  Created by dragon on 3/21/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CardIO/CardIO.h>

@class CardCaptureViewController;
@protocol CardCaptureViewControllerDelegate <NSObject>

- (void) cardCaptureViewController:(CardCaptureViewController *)vc didScanCard:(CardIOCreditCardInfo *)cardInfo;

@end

@interface CardCaptureViewController : UIViewController<CardIOViewDelegate>

@property (nonatomic,strong) IBOutlet CardIOView *cardIOView;
@property (nonatomic, weak) id<CardCaptureViewControllerDelegate> delegate;
@end
