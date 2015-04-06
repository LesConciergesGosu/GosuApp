//
//  TaskMessageViewController.m
//  Gosu
//
//  Created by dragon on 3/23/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "TaskMessageViewController.h"
#import <Reachability.h>
#import <libkern/OSAtomic.h>

#import "Task+Extra.h"
#import "Message+Extra.h"
#import "User+Extra.h"

#import "BubbleMessage.h"
#import "DataManager.h"

#import "MessageTimeCell.h"
#import "MessageCell.h"
#import "AudioManager.h"
#import "DotSpinView.h"
#import "NSString+Drawing.h"
#import <UIImage-Categories/UIImage+Resize.h>
#import <SpeechKit/SpeechKit.h>

#import "ProfileViewController.h"

#define MAX_ENTRIES_LOADED 25
#define PHOTO_MAX_WIDTH     130
#define BUBBLE_MAX_WIDTH    160
#define BUBBLE_MIN_WIDTH    60
#define BUBBLE_MIN_HEIGHT   60

@interface TaskMessageViewController ()<MessageCellDelegate, SKRecognizerDelegate/*, AudioRecordDelegate*/>
{
    BOOL _viewLoaded;
    BOOL _hasPendingReloadRequest;
    BOOL _isGrouping;
    BOOL _hasPendingGroupingRequest;
    volatile int32_t _refreshLock;
    
    VoiceRecordingState voiceRecordingState;
    
}
/**
 count of the fetched objects only
 */
@property (nonatomic) NSInteger lastStableIndex;
@property (nonatomic, strong) NSDate *lastStableDate;

/**
 contains the dirty objects as well as fetched objects.
 */
@property (nonatomic, strong) NSMutableArray *chattingHistory;

/**
 contains the bubble objects, used to show messages in collection view.
 */
@property (nonatomic, strong) NSMutableArray *groupedMessages;

/**
 voice recording path - temporary file
 */
@property (nonatomic, strong) NSString *voicePath;

//@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) SKRecognizer *speechRecognizer;
@property (nonatomic, strong) NSTimer *speechTimer;
@property (nonatomic, strong) NSDate *speechStartTime;
@end

@implementation TaskMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#ifdef DEBUG
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DLog(@"Task Message View Controller is deallocated.");
}
#endif

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"MESSAGES";
    _viewLoaded = NO;
    _hasPendingReloadRequest = NO;
    _isGrouping = NO;
    _hasPendingGroupingRequest = NO;
    voiceRecordingState = VR_IDLE;
    
    _refreshLock = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_viewLoaded)
    {
        self.chattingHistory = [NSMutableArray array];
        
//        self.refreshControl = [[UIRefreshControl alloc] init];
//        self.refreshControl.tintColor = [UIColor grayColor];
//        [self.refreshControl addTarget:self
//                                action:@selector(refreshControlValueChanged:)
//                      forControlEvents:UIControlEventValueChanged];
//        [self.tableView addSubview:self.refreshControl];
        [self.tableView setAlwaysBounceVertical:YES];
        
        self.roomTitleLabel.text = [self task].title;
        
        // pull the message history from the cache
        
        self.lastStableDate = nil;
        self.lastStableIndex = 0;
        
        NSArray *array = self.task.messages ? [self.task.messages array] : [NSArray array];
        
        for (int i = 0; i < [array count]; i ++) {
            
            Message *msg = array[i];
            
            if ([msg.draft boolValue] == NO &&
                ( self.lastStableDate == nil || [self.lastStableDate compare:msg.createdAt] == NSOrderedAscending)) {
                self.lastStableDate = msg.createdAt;
                self.lastStableIndex = i;
            }
        }
        
        self.chattingHistory = [NSMutableArray arrayWithArray:array];
        
        [self groupBubbleDataInBackgroundWithSkip:0];
        
        _viewLoaded = YES;
        
        [self fetchNewMessages:nil];
    }
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
    
	if (status == NotReachable){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network"
														message:@"Please check your internet connection."
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
        return;
	}
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[self txtMessage] resignFirstResponder];
}

- (void) applicationDidBecomeActive:(id)sender
{
    [self fetchNewMessages:nil];
}

- (void) reloadData
{
    [self fetchNewMessages:nil needToBePending:YES];
}

- (void) fetchNewMessages:(id)sender
{
    [self fetchNewMessages:sender needToBePending:NO];
}

/**
 
 Fetch new messages only if the fetching thread is idle.
 
 If <b>needToBePending</b> is true, the fetching thread fetch the new messages again
 after finish its operation.
 
 */

- (void) fetchNewMessages:(id)sender needToBePending:(BOOL)needPending
{
    if (_refreshLock > 0) {
        if (needPending) _hasPendingReloadRequest = YES;
        return;
    }
    
    OSAtomicAdd32(1, &_refreshLock);
    
    _hasPendingReloadRequest = NO;
    
    __weak TaskMessageViewController *wsef = self;
    
    [self fetchOnlyNewMessagesWithCompletion:^(NSInteger value, NSString *errorDesc) {
        TaskMessageViewController *sself = wsef;
        if (sself) {
            
            OSAtomicAdd32(-1, &_refreshLock);
            
            if (_hasPendingReloadRequest || value >= MAX_MESSAGES_LOADED_ONCE) {
                [sself fetchNewMessages:nil];
            } else {
                NSManagedObjectContext *context = sself.task.managedObjectContext;
                [context performBlock:^{
                    sself.task.unread = @(0);
                    if ([context hasChanges]) {
                        [context saveRecursively];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationUpdatedUnreadMessageCounts object:nil];
                    }
                }];
                
            }
        }
    }];
}

#pragma mark Reload History


- (void) fetchOnlyNewMessagesWithCompletion:(GIntBlock)completion
{
    
    __weak TaskMessageViewController *wself = self;
    
    [self.task fetchMessagesSince:self.lastStableDate completionHandler:^(NSInteger value, NSString *errorDesc) {
        
        TaskMessageViewController *sself = wself;
        
        if (sself) {
            
            DLog(@"%d messages fetched!", (int)value);
            
            if (value > 0) {
                
                NSArray *array = [sself.task.messages array];
                NSInteger skip = sself.lastStableIndex;
                
                for (NSInteger i = skip; i < [array count]; i ++) {
                    Message *msg = array[i];
                    if ([msg.draft boolValue] == NO &&
                        ( sself.lastStableDate == nil || [sself.lastStableDate compare:msg.createdAt] == NSOrderedAscending)) {
                        sself.lastStableDate = msg.createdAt;
                        sself.lastStableIndex = i;
                    }
                }
                
                sself.chattingHistory = [NSMutableArray arrayWithArray:array];
                [sself groupBubbleDataInBackgroundWithSkip:skip];
            }
            
            completion(value, errorDesc);
        }
        
    }];
//    [self.task fetchMessagesWithSkip:skip CompletionHandler:^(NSInteger value, NSString *errorDesc) {
//        
//        TaskMessageViewController *sself = wself;
//        
//        if (sself) {
//            
//            if (value > 0) {
//                NSArray *array = [sself.task.messages array];
//                
//                NSInteger index = skip;
//                for (NSInteger i = skip; i < [array count]; i ++) {
//                    Message *msg = array[i];
//                    if ([msg.draft boolValue] == NO)
//                    {
//                        index = i;
//                        break;
//                    }
//                }
//                
//                sself.stableCount = index;
//                sself.chattingHistory = [NSMutableArray arrayWithArray:array];
//                [sself groupBubbleDataInBackgroundWithSkip:skip];
//            }
//            completion();
//        }
//    }];
}


- (void) groupBubbleDataInBackgroundWithSkip:(NSInteger)skip
{
    
    // we need to avoid the duplicated call,
    // still need to make the request pending as possible, process later.
    
    if (_isGrouping) {
        _hasPendingGroupingRequest = YES;
        return;
    }
    
    _hasPendingGroupingRequest = NO;
    _isGrouping = YES;
    
    User *me = [User currentUser];
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        TaskMessageViewController *sself = wself;
        
        if (!sself)
            return;
        
        UIFont *font = [UIFont systemFontOfSize:15.0f];
        NSArray *messages = [sself.chattingHistory copy];
        NSMutableArray *bubbles = [NSMutableArray arrayWithArray:[sself.groupedMessages subarrayWithRange:NSMakeRange(0, skip)]];
        
        User *lastAuthor = skip > 1 ? [messages[skip - 1] author] : nil;
        
        NSDate *lastDate = [NSDate dateWithTimeIntervalSince1970:0];
        
        for (NSInteger i = skip; i < [messages count]; i++)
        {
            
            BubbleMessage *bubble;
            User *author;
//            if (i == 0) // task description
//            {
//                bubble = [BubbleMessage bubbleWithTask:self.task];
//                bubble.type = MessageTypeText;
//                bubble.isMe = self.task.customer == me;
//            }
//            else
            {
                author = [(Message *) messages[i] author];
                bubble = [BubbleMessage bubbleWithMessage:messages[i]];
                bubble.isMe = author == me;
                
                if (i == 0)
                {
                    bubble.showAvatar = YES;
                    lastDate = bubble.date;
                    lastAuthor = author;
                }
                else
                {
                    if (lastAuthor != author || [bubble.date timeIntervalSinceDate:lastDate] > 120) {
                        bubble.showAvatar = YES;
                        lastAuthor = author;
                    } else {
                        bubble.showAvatar = NO;
                    }
                    lastDate = bubble.date;
                }
                
            }
            
            
            switch (bubble.type) {
                case MessageTypeText:
                case MessageTypeNotification:
                {
                    CGSize textSz = [bubble.text sizeWithFont:font fitToSize:CGSizeMake(BUBBLE_MAX_WIDTH - 30, 1000)];
                    
                    
                    bubble.bubbleSize = CGSizeMake(MAX(textSz.width + 30, 80),
                                                   MAX(textSz.height + 10, BUBBLE_MIN_HEIGHT));
                    
                }
                    break;
                case MessageTypePhoto:
                {
                    CGFloat width =  [bubble photoSize].width;
                    CGFloat height = [bubble photoSize].height;
                    
                    CGFloat max = MAX(width, height);
                    
                    if (max > PHOTO_MAX_WIDTH) {
                        width = width / max * PHOTO_MAX_WIDTH;
                        height = height / max * PHOTO_MAX_WIDTH;
                    }
                    
                    bubble.bubbleSize = CGSizeMake(MAX(10 + width, BUBBLE_MIN_WIDTH),
                                                   MAX(height, BUBBLE_MIN_HEIGHT));
                    
                }
                    break;
                    
                case MessageTypeDescription:
                {
                    CGSize textSz = [bubble.text sizeWithFont:font fitToSize:CGSizeMake(BUBBLE_MAX_WIDTH - 30, 1000)];
                    
                    
                    bubble.bubbleSize = CGSizeMake(MAX(textSz.width + 30, 80),
                                                   MAX(textSz.height + 45, BUBBLE_MIN_HEIGHT));
                    
                }
                    break;
                    
                case MessageTypeAudio:
                    bubble.bubbleSize = CGSizeMake(BUBBLE_MIN_WIDTH,
                                                   BUBBLE_MIN_HEIGHT - 10);
                    break;
                    
                default:
                    
                    break;
            }
            
            if (bubble.showAvatar) {
                if (!bubble.isMe) {
                    CGSize bubbleSize = bubble.bubbleSize;
                    bubbleSize.width = MAX(BUBBLE_MAX_WIDTH, bubbleSize.width);
                    bubble.bubbleSize = bubbleSize;
                }
                bubble.height = bubble.bubbleSize.height + 20;
            } else {
                bubble.height = bubble.bubbleSize.height + 10;
            }
            
            [bubbles addObject:bubble];
        }
        
        __weak TaskMessageViewController *wSelf = sself;
        dispatch_async(dispatch_get_main_queue(), ^{
            TaskMessageViewController *sSelf = wSelf;
            if (sSelf) {
                sSelf.groupedMessages = bubbles;
                [sSelf.tableView reloadData];
                NSInteger index = [sSelf.tableView numberOfRowsInSection:0] - 1;
                if (index >= 0)
                    [sSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
                
                _isGrouping = NO;
                if (_hasPendingGroupingRequest) {
                    [sSelf groupBubbleDataInBackgroundWithSkip:skip];
                }
            }
        });
    });
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.txtMessage == textField)
    {
        if ([self.txtMessage.text length] > 0)
        {
            __weak TaskMessageViewController *wself = self;
            Message *object = [Message sendMessage:[self txtMessage].text forTask:self.task fromAuthor:[User currentUser] withCompletionHandler:^(BOOL success, NSString *errorDesc) {
                TaskMessageViewController *sself = wself;
                if (sself)
                    [sself fetchNewMessages:nil];
            }];
            [self.chattingHistory addObject:object];
            [self groupBubbleDataInBackgroundWithSkip:self.lastStableIndex];
        }
        
        [self txtMessage].text = @"";
        
        [self fetchNewMessages:nil];
    }
    
    return YES;
}

- (void) keyboardWillShow:(id)sender
{
    
    // When keyboard appear, we need to shrink the height of contentView with
    // an animation appropriate with keyboard show animation
    
    NSDictionary *userInfo = [sender userInfo];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect frame = self.view.bounds;
    CGRect contentFrame = self.contentView.frame;
    CGFloat height = frame.size.height - contentFrame.origin.y;
    
    contentFrame.size.height = height - endFrame.size.height;
    [UIView animateWithDuration:duration delay:0 options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.contentView.frame = contentFrame;
        NSInteger lastIndex = [self.tableView numberOfRowsInSection:0] - 1;
        if (lastIndex >= 0)
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastIndex inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:NO];
    } completion:^(BOOL finished) {
    }];
}

- (void) keyboardWillHide:(id)sender
{
    
    // When keyboard disppear, we need to expand the height of contentView with
    // an animation appropriate with keyboard hide animation
    
    NSDictionary *userInfo = [sender userInfo];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    CGRect frame = self.view.bounds;
    CGRect contentFrame = self.contentView.frame;
    contentFrame.size.height = frame.size.height - contentFrame.origin.y;
    [UIView animateWithDuration:duration delay:0 options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.contentView.frame = contentFrame;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - Actions

- (IBAction)onSendPhoto:(id)sender
{
    ////////////////////////////////////////////////////////
    //////////////      Take a Photo     ///////////////////
    //////////////  Choose from Library  ///////////////////
    //////////////        Cancel         ///////////////////
    ////////////////////////////////////////////////////////
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Take a Photo" otherButtonTitles:@"Choose from Library", nil];
        [actionSheet showInView:sender];
    }
    else {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (IBAction) onHoldVoiceButton:(UILongPressGestureRecognizer *)sender
{
    
    switch ([sender state]) {
            
        case UIGestureRecognizerStateBegan:
            if (voiceRecordingState == VR_IDLE) {
                voiceRecordingState = VR_INITIAL;
                [self.voiceRecordingIndicator startAnimationClockWise:YES];
                self.speechRecognizer = [[DataManager manager] createSpeechKitRecognizerWithDelegate:self];
            }
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
            self.title = @"MESSAGES";
            if (voiceRecordingState == VR_INITIAL)
                [self.speechRecognizer cancel];
            else
                [self.speechRecognizer stopRecording];
            
        default:
            break;
    }
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.groupedMessages count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MessageCell *cell;
    
    if (indexPath.row < [self.groupedMessages count]) {
        
        BubbleMessage *message = self.groupedMessages[indexPath.row];
        
        NSString *cellID = @"MyMessageCell";
        
        if (message.type == MessageTypeDescription)
        {
            if (message.isMe)
                cellID = @"MyMessageTaskDescCell";
            else
                cellID = @"OtherMessageTaskDescCell";
        }
        else
        {
            if (message.isMe) {
                if (message.showAvatar)
                    cellID = @"MyMessageHeaderCell";
                else
                    cellID = @"MyMessageCell";
            } else {
                if (message.showAvatar)
                    cellID = @"OtherMessageHeaderCell";
                else
                    cellID = @"OtherMessageCell";
            }
        }
        
        cell = [aTableView dequeueReusableCellWithIdentifier:cellID];
        cell.delegate = self;
        [cell setMessage:message];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row < [self.groupedMessages count]) {
        BubbleMessage *message = self.groupedMessages[indexPath.row];
        return message.height;
    }
    
    return 0;
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView)
    {
        [self.txtMessage resignFirstResponder];
    }
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate)
        return;
    
    if ([scrollView contentOffset].y >= [scrollView contentSize].height - scrollView.frame.size.height)
        [self fetchNewMessages:nil];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView contentOffset].y >= [scrollView contentSize].height - scrollView.frame.size.height)
        [self fetchNewMessages:nil];
}

- (void) messageCell:(MessageCell *)cell goProfileForMessage:(BubbleMessage *)message
{
    if (!message || !message.authorId)
        return;
    
    User *user = [[DataManager manager] managedObjectWithID:message.authorId withEntityName:@"User"];
    
    ProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    vc.noMenu = YES;
    vc.user = user;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark Audio Recording Delegate

- (void)recognizerDidBeginRecording:(SKRecognizer *)recognizer
{
    
    voiceRecordingState = VR_RECORDING;
    self.title = @"Recording...";
    
    self.speechStartTime = [NSDate date];
    self.speechTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                                        target:self
                                                      selector:@selector(updateRecordingDuration:)
                                                      userInfo:nil repeats:YES];
}

- (void)recognizerDidFinishRecording:(SKRecognizer *)recognizer
{
    
    voiceRecordingState = VR_PROCESSING;
    self.title = @"Processing...";
    
    [self.voiceRecordingIndicator stopAnimation];
    [self.voiceRecordingIndicator startAnimationClockWise:NO];
    [self.speechTimer invalidate];
    self.speechTimer = nil;
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results
{
    
    long numOfResults = [results.results count];
    
    voiceRecordingState = VR_IDLE;
    
    if (numOfResults > 0)
        self.txtMessage.text = [results firstResult];
    
	if (numOfResults > 1)
		DLog(@"alternative text : %@",[[results.results subarrayWithRange:NSMakeRange(1, numOfResults-1)] componentsJoinedByString:@"\n"]);
    
    if (results.suggestion)
        DLog(@"suggestion : %@", results.suggestion);
    
    self.title = @"MESSAGES";
    [self.voiceRecordingIndicator stopAnimation];
	self.speechRecognizer = nil;
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion
{
    
    voiceRecordingState = VR_IDLE;
    
    DLog(@"Recognizer error : %@", error);
    
    if (suggestion) {
        DLog(@"suggestion : %@", suggestion);
        
    }
    
    self.title = @"MESSAGES";
    [self.voiceRecordingIndicator stopAnimation];
	self.speechRecognizer = nil;
}

- (NSString *)formattedStringForTime:(NSTimeInterval)interval
{
    int time = (int)interval;
    int secs = time % 60;
	int min = time / 60;
    
    NSString *formattedTime;
	if (interval < 60){
        formattedTime = [NSString stringWithFormat:@"00:%02d", time];
    } else {
        formattedTime =	[NSString stringWithFormat:@"%02d:%02d", min, secs];
    }
    
    return formattedTime;
}

- (void) updateRecordingDuration:(id)sender
{
    NSDate *now = [NSDate date];
    self.title = [self formattedStringForTime:[now timeIntervalSinceDate:self.speechStartTime]];
}

//
//
//- (void)audioManager:(AudioManager *)manager didFinishWithSucess:(BOOL)success recordedPath:(NSString *)path duration:(NSTimeInterval)duration
//{
//    if (success)
//    {
//        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
//        {
//            __weak TaskMessageViewController *wself = self;
//            
//            Message *object = [Message sendVoice:path forTask:self.task fromAuthor:[User currentUser] withDuration:duration CompletionHandler:^(BOOL success, NSString *errorDesc) {
//                
//                // after upload the audio on the server, fetch any new chatting history.
//                TaskMessageViewController *sself = wself;
//                if (sself)
//                    [sself fetchNewMessages:nil];
//            }];
//            
//            // show the draft message, first.
//            [self.chattingHistory addObject:object];
//            
//            [self groupBubbleDataInBackgroundWithSkip:self.stableCount];
//        }
//    }
//    else
//    {
//        self.voicePath = nil;
//    }
//}
//
//- (void)audioManager:(AudioManager *)manager UpdateRecordingTime:(NSTimeInterval)interval
//{
//    self.title = [self formattedStringForTime:interval];
//}

#pragma mark Side Menu Gesture Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panner
{
    return NO;
}

#pragma mark UIActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        
        if (buttonIndex == actionSheet.destructiveButtonIndex)
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        else
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark UIImagePicker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image;
    
    if ((image = [info objectForKey:UIImagePickerControllerEditedImage]) ||
        (image = [info objectForKey:UIImagePickerControllerOriginalImage]) )
    {
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            CGSize newSize = image.size;
            CGFloat max = MAX(newSize.width, newSize.height);
            
            if (max > 160) {
                newSize.width = newSize.width * 160 / max;
                newSize.height = newSize.height * 160 / max;
                image = [image resizedImage:newSize interpolationQuality:kCGInterpolationDefault];
            }
        }
        
        __weak TaskMessageViewController *wself = self;
        Message *object = [Message sendPhoto:image forTask:self.task fromAuthor:[User currentUser] withCompletionHandler:^(BOOL success, NSString *errorDesc) {
            // after upload the photo on the server, fetch any new chatting history.
            TaskMessageViewController *sself = wself;
            if (sself)
                [sself fetchNewMessages:nil];
        }];
        
        // show the draft message, first.
        [self.chattingHistory addObject:object];
        [self groupBubbleDataInBackgroundWithSkip:self.lastStableIndex];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


@end
