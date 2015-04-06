//
//  MessageCell.h
//  Gosu
//
//  Created by dragon on 3/24/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDownloadManager.h"
#import "AudioManager.h"

@class BubbleMessage;
@class RoundImageView;
@class MDRadialProgressView;

@class MessageCell;
@protocol MessageCellDelegate <NSObject>

- (void)messageCell:(MessageCell *)cell goProfileForMessage:(BubbleMessage *)message;

@end

@interface MessageCell : UITableViewCell<GDownloadManagerDelegate, AudioPlayDelegate>

@property (nonatomic, weak) IBOutlet UIView *avatorContainer;
@property (nonatomic, weak) IBOutlet RoundImageView *avatorView;
@property (nonatomic, weak) IBOutlet UIView *msgView;
@property (nonatomic, weak) IBOutlet UIImageView *msgPhotoView;
@property (nonatomic, weak) IBOutlet UILabel *msgTextLabel;
@property (nonatomic, weak) IBOutlet UILabel *msgTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *msgAuthorLabel;
@property (nonatomic, weak) IBOutlet UIButton *msgAudioButton;
@property (nonatomic, weak) IBOutlet UIButton *msgImageButton;
@property (nonatomic, weak) IBOutlet MDRadialProgressView *progressView;
@property (weak) id<MessageCellDelegate> delegate;

- (void) setMessage:(BubbleMessage *)message;
- (IBAction)onTapPhotoView:(id)sender;
@end
