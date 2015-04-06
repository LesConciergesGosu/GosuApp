//
//  MessageCell.m
//  Gosu
//
//  Created by dragon on 3/24/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "MessageCell.h"
#import "BubbleMessage.h"
#import "RoundImageView.h"
#import <MDRadialProgress/MDRadialProgressView.h>
#import <MDRadialProgress/MDRadialProgressTheme.h>
#import "GDownloadManager.h"
#import "DataManager.h"

static NSDateFormatter *msgTimeFormatter = nil;

@interface MessageCell()

@property (weak) BubbleMessage *msg;
@end

@implementation MessageCell

- (void) dealloc
{
    [GDownloadManager detachListener:self];
    [AudioManager detachPlayListener:self];
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    
    self.progressView.hidden = YES;
    [GDownloadManager detachListener:self];
    [AudioManager detachPlayListener:self];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setMessage:(BubbleMessage *)aMessage
{
    
    if (msgTimeFormatter == nil)
    {
        msgTimeFormatter = [[NSDateFormatter alloc] init];
        [msgTimeFormatter setDateFormat:@"hh:mm a"];
    }
    
    self.msg = aMessage;
    
    // set bubble frame
    CGRect bubbleFrame = self.msgView.frame;
    
    if (aMessage.isMe) {
        bubbleFrame.size.width= aMessage.bubbleSize.width;
        self.msgView.frame = bubbleFrame;
    } else {
        CGFloat right = CGRectGetMaxX(bubbleFrame);
        bubbleFrame.size.width= aMessage.bubbleSize.width;
        bubbleFrame.origin.x = right - bubbleFrame.size.width;
        self.msgView.frame = bubbleFrame;
    }
    
    // need to show avator & date/time
    if (aMessage.showAvatar)
    {
        NSString *authorPhoto = aMessage.authorPhoto;
        
        self.avatorView.image = [UIImage imageNamed:@"buddy.png"];
        if (authorPhoto) {
            __weak typeof(self) wself = self;
            [[DataManager manager] loadImageURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:authorPhoto]] handler:^(UIImage *image) {
                MessageCell *sself = wself;
                if (sself && sself.msg == aMessage && image) {
                    sself.avatorView.image = image;
                }
            }];
        }
        
        if (!aMessage.isMe) {
            self.msgTimeLabel.text = [msgTimeFormatter stringFromDate:aMessage.date];
            self.msgAuthorLabel.text = aMessage.authorName;
            
            CGRect timeFrame = [self.msgTimeLabel frame];
            timeFrame.origin.x = CGRectGetMinX(bubbleFrame) + 10;
            self.msgTimeLabel.frame = timeFrame;
        } else {
            
            self.msgTimeLabel.text = [msgTimeFormatter stringFromDate:aMessage.date];
            CGRect timeFrame = [self.msgTimeLabel frame];
            timeFrame.origin.x = CGRectGetMaxX(bubbleFrame) - 10 - timeFrame.size.width;
            self.msgTimeLabel.frame = timeFrame;
        }
    }
    
    // show main contents (photo/audio/text)
    switch (aMessage.type) {
            
        case MessageTypeText:
        case MessageTypeNotification:
        {
            // just show the text only.
            self.msgTextLabel.hidden = NO;
            self.msgTextLabel.text = [self msg].text;
            
            self.msgPhotoView.hidden = YES;
            self.msgAudioButton.hidden = YES;
            self.msgImageButton.hidden = YES;
        }
            break;
            
        case MessageTypePhoto:
        {
            // just show the photo only.
            self.msgPhotoView.image = nil;
            self.msgPhotoView.hidden = NO;
            self.msgTextLabel.hidden = YES;
            self.msgAudioButton.hidden = YES;
            self.msgImageButton.hidden = NO;
            
            NSString *attachment = aMessage.attachment;
            
            if (attachment)
            {
                NSURL *url = [NSURL URLWithString:attachment];
                [GDownloadManager attachListener:self toURL:url];
                
                self.progressView.hidden = NO;
                self.progressView.progressCounter = 1;
                
                [GDownloadManager downloadImageWithURL:url useCache:YES];
            }
            else
            {
                self.progressView.hidden = YES;
            }
            break;
        }
            
        case MessageTypeDescription:
        case MessageTypeAudio:
        {
            
            // just show the audio only.
            // if the data have text, show it as well.
            
            self.msgTextLabel.text = [self msg].text;
            
            self.msgTextLabel.hidden = NO;
            self.msgPhotoView.hidden = YES;
            self.msgAudioButton.hidden = NO;
            self.msgImageButton.hidden = YES;
            
            NSString *attachment = aMessage.attachment;
            if (attachment)
            {
                
                NSURL *url = [NSURL URLWithString:attachment];
                NSString *localPath = [GDownloadManager cachedPathForURL:url];
                [GDownloadManager attachListener:self toURL:url];
                [AudioManager attachPlayListener:self toURL:[NSURL fileURLWithPath:localPath]];
                
                self.msgAudioButton.selected = NO;
                
                if ([GDownloadManager hasDiskCacheForURL:url]) {
                    self.msgAudioButton.enabled = YES;
                    self.progressView.hidden = YES;
                } else {
                    self.msgAudioButton.enabled = NO;
                    self.progressView.hidden = NO;
                    self.progressView.progressCounter = 1;
                    [GDownloadManager downloadItemWithURL:url useCache:YES];
                }
            } else {
                self.progressView.hidden = YES;
                self.msgAudioButton.enabled = NO;
            }
            
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)onTapPhotoView:(id)sender
{
    if (self.msg && self.delegate) {
        [self.delegate messageCell:self goProfileForMessage:self.msg];
    }
}

- (IBAction)openImage:(id)sender
{
    if (self.msg.type == MessageTypePhoto && self.msg.attachment) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.msg.attachment]];
    }
}

- (IBAction)onVoicePlay:(id)sender
{
    NSString *attachment = self.msg.attachment;
    
    if (attachment)
    {
        NSURL *url = [NSURL URLWithString:attachment];
        NSString *path = [GDownloadManager cachedPathForURL:url];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            
            NSURL *localURL = [NSURL fileURLWithPath:path];
            
            if ([(UIButton *)sender isSelected]) {
                [[AudioManager manager] stopPlayingAtURL:localURL];
            } else {
                [[AudioManager manager] playAudioAtURL:localURL];
            }
        }
    }
}

#pragma mark File Download Progress

- (void) downloadManagerDidProgress:(float)progress {
    self.progressView.progressCounter = (NSUInteger) (100 * progress);
}

- (void) downloadManagerDidFinish:(BOOL)success response:(id)response {
    self.progressView.hidden = YES;
    self.msgAudioButton.enabled = YES;
    
    if (self.msg.type == MessageTypePhoto)
    {
        self.msgPhotoView.image = response;
    }
}

#pragma mark Audio Play Delegate

- (void) player:(AVPlayer *)player reportTime:(NSTimeInterval)time duration:(NSTimeInterval)duration {
    DLog(@"report time : %f", time);
    if (time > 0)
        self.msgAudioButton.selected = YES;
    else
        self.msgAudioButton.selected = NO;
}

- (void) player:(AVPlayer *)player statusDidChange:(AudioPlayState)state {
    DLog(@"status changed : %d", (int)state);
    //self.msgAudioButton.selected = (state == AudioPlayStatePlaying);
}

@end
