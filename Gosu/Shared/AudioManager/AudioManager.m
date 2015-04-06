//
//  AudioManager.m
//  Gosu
//
//  Created by dragon on 4/5/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "AudioManager.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioPlayHandler.h"
@interface AudioManager()<AVAudioRecorderDelegate>
{
}

@property (nonatomic, strong) NSMutableDictionary *playListeners;


@property (nonatomic, strong) AVAudioRecorder* avRecorder;
@property (nonatomic, strong) AVAudioSession* avSession;
@property (nonatomic)  NSTimeInterval recordDuration;
@property (nonatomic, retain) NSTimer* recordTimer;

@property (strong) NSURL *audioURL;
@property (strong) AVPlayer *audioPlayer;
@property (strong) id avTimeObserver;
@end

@implementation AudioManager

+ (AudioManager *)manager {
    static id instance;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[[self class] alloc] init];
	});
	
	return instance;
}

- (id) init
{
    self = [super init];
    
    if (self) {
        self.avTimeObserver = nil;
        self.audioPlayer = nil;
        self.playListeners = [NSMutableDictionary dictionary];
    }
    
    return self;
}

#pragma mark - Audio Recording Manager


- (BOOL)startRecordingWithDelegate:(id<AudioRecordDelegate>)aDelegate
{
    self.recordingDelegate = aDelegate;
    
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
    NSError* error = nil;
    
    if (self.avSession == nil) {
        // create audio session
        self.avSession = [AVAudioSession sharedInstance];
    }
    
    // create AVAudioRecorder
    if (self.avRecorder)
    {
        [self.avRecorder stop];
        self.avRecorder.delegate = nil;
        self.avRecorder = nil;
    }
    
    NSURL *audioRecordingURL = [NSURL fileURLWithPath:generateNewTemporaryFile(@"wav")];
    self.avRecorder = [[AVAudioRecorder alloc] initWithURL:audioRecordingURL settings:nil error:&error];
    if (error) {
        NSLog(@"Failed to initialize AVAudioRecorder: %@\n", [error localizedDescription]);
        self.avRecorder = nil;
        self.recordingDelegate = nil;
        return NO;
        
    } else if ([self.avRecorder prepareToRecord]){
        self.avRecorder.delegate = self;
    }
    
    // check whether we have the access to the AVAudioSession
    [self.avSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
    AudioSessionSetActive(true);
    
    [self.avSession setActive: YES error: &error];
    
    
    if(error) {
        self.recordingDelegate = nil;
        self.avRecorder = nil;
        return NO;
    } else {
        if ([self.avRecorder record]) {
            self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target: self selector:@selector(updateRecordingTime:) userInfo:nil repeats:YES ];
        } else {
            self.avRecorder = nil;
            self.recordingDelegate = nil;
            return NO;
        }
    }
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
    
    return YES;
}

- (void)stopRecording
{
    [self.avRecorder stop];
}

- (void) cancelRecording
{
    if (self.avRecorder)
    {
        self.avRecorder.delegate = nil;
        [self stopRecordingCleanupForRecorder:self.avRecorder];
    }
}

/*
 * helper method to clean up when stop recording
 */
- (void) stopRecordingCleanupForRecorder:(AVAudioRecorder *)recorder
{
    if (self.avRecorder.recording) {
        [self.avRecorder stop];
    }
    
    if (self.avSession) {
        // deactivate session so sounds can come through
        //[self.avSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        //[self.avSession  setActive: NO error: nil];
    }
    
    // issue a layout notification change so that VO will reannounce the button label when recording completes
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

- (void)updateRecordingTime:(id)sender
{
    self.recordDuration = [self avRecorder].currentTime;
    [self.recordingDelegate audioManager:self UpdateRecordingTime:self.recordDuration];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder*)recorder successfully:(BOOL)flag
{
    
    if (recorder == self.avRecorder)
        [self.recordTimer invalidate];
    
    [self stopRecordingCleanupForRecorder:recorder];
    
    // generate success result
    if (flag) {
        [self.recordingDelegate audioManager:self
                         didFinishWithSucess:YES
                                recordedPath:[recorder.url path]
                                    duration:self.recordDuration];
        self.recordingDelegate = nil;
        
    } else {
        
        [self.recordingDelegate audioManager:self
                         didFinishWithSucess:NO
                                recordedPath:nil
                                    duration:0];
        self.recordingDelegate = nil;
        
        [[NSFileManager defaultManager] removeItemAtURL:recorder.url error:nil];
    }
    
    self.avRecorder = nil;
}
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    
    if (recorder == self.avRecorder)
        [self.recordTimer invalidate];
    
    [self stopRecordingCleanupForRecorder:recorder];
    [self.recordingDelegate audioManager:self didFinishWithSucess:NO recordedPath:nil duration:0];
    self.recordingDelegate = nil;
    [[NSFileManager defaultManager] removeItemAtURL:recorder.url error:nil];
}

#pragma mark - Audio Play Manager

#pragma mark Public Interface



+ (void) attachPlayListener:(id<AudioPlayDelegate>)listener toURL:(NSURL*)url
{
    [[self manager] attachNewHandlerWithListener:listener toURL:url];
}

+ (void) detachPlayListener:(id<AudioPlayDelegate>)listener;
{
    [[self manager] removeHandlerWithListener:listener];
}

- (void) stopPlayingAtURL:(NSURL *)url
{
    if (self.audioPlayer && [self.audioURL isEqual:url]) {
        [self stopPlaying];
    }
}

- (BOOL) playAudioAtURL:(NSURL *)url {
    
    BOOL res = NO;
    
    BOOL duplicated = NO;
    
    if (self.audioPlayer && [self.audioURL isEqual:url]) {
        
        [self.audioPlayer seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
        
        duplicated = YES;
        
        res = YES;
        
    }
    
    if (!duplicated) {
        
        [self removeAVPlayer];
        
        self.audioURL = url;
        
        res = [self loadAVPlayer];
        
        for (NSString *key in [self.playListeners allKeys]) {
            NSString *myKey = url.absoluteString;
            if (![key isEqual:myKey]) {
                for (AudioPlayHandler *handler in [self.playListeners objectForKey:key]) {
                    [handler.delegate player:nil statusDidChange:AudioPlayStateStopped];
                }
            }
        }
    }
    
    if (res) {
        
        [self.audioPlayer play];
        
        [self reportPlayingState:AudioPlayStatePlaying];
        
    }
    
    return res;
}

- (void) stopPlaying {
    
    if (self.audioPlayer) {
        
        [self.audioPlayer pause];
        
        [self.audioPlayer seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
        
        //[self reportPlayingState:AudioPlayStateStopped];
    }
}

#pragma mark Listeners


- (void)removeHandlerWithListener:(id)listener
{
    for (int i = self.playListeners.allKeys.count - 1; i >= 0; i-- )
    {
        id key = self.playListeners.allKeys[i];
        NSMutableArray *array = [self.playListeners objectForKey:key];
        
        for (int j = array.count - 1; j >= 0; j-- )
        {
            AudioPlayHandler *handler = array[j];
            if (handler.delegate == listener)
            {
                [array removeObject:handler];
            }
        }
    }
}

- (void) attachNewHandlerWithListener:(id<AudioPlayDelegate>)listener
                                toURL:(NSURL*)url
{
    //We should remove the old handler
    //Allow only 1 delegate to listen ot a set of URLs, maybe in the future we can have 1 delegate listening to more than a set of urls
    
    NSString *key = url.absoluteString;
    
    [self removeHandlerWithListener:listener];
    
    NSMutableArray *handlers = [self.playListeners objectForKey:key];
    
    if (!handlers)
        handlers = [NSMutableArray new];
    
    AudioPlayHandler *handler = [AudioPlayHandler handlerWithURL:url delegate:listener];
    
    
    [handlers addObject:handler];
    [self.playListeners setObject:handlers forKey:key];
}

#pragma mark Time Observer
- (void) removeTimeObserverFromPlayer {
    
    if (self.avTimeObserver) {
        
        if (self.audioPlayer) {
            [self.audioPlayer removeTimeObserver:self.avTimeObserver];
        }
        
        self.avTimeObserver = nil;
    }
}

- (void) addTimeObserverToPlayer {
    
    if (self.avTimeObserver)
        return;
    
    double interval = 0.1;
    AVAsset *asset = (AVAsset *)self.audioPlayer.currentItem.asset;
    
    if (asset) {
        
        double duration = CMTimeGetSeconds([asset duration]);
        
        if (isfinite(duration)) {
            
            interval = 0.5 * duration / 200;
        }
    }
    
    __weak typeof (self) wself = self;
    
    self.avTimeObserver = [self.audioPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        AudioManager *sself = wself;
        [sself reportPlayingProgress];
    }];
}

#pragma mark report progress & playing state

- (void) reportPlayingProgress {
    
    AVAsset *asset = (AVAsset *)self.audioPlayer.currentItem.asset;
    
    if (!asset)
        return;
    
    double duration = CMTimeGetSeconds([asset duration]);
    
    if (isfinite(duration)) {
        
        double time = CMTimeGetSeconds([self.audioPlayer currentTime]);
        
        NSMutableArray *handlers = [self.playListeners objectForKey:self.audioURL.absoluteString];
        //Inform the handlers
        [handlers enumerateObjectsUsingBlock:^(AudioPlayHandler *handler, NSUInteger idx, BOOL *stop) {
            
            if ([handler.delegate respondsToSelector:@selector(player:reportTime:duration:)]) {
                [handler.delegate player:self.audioPlayer reportTime:time duration:duration];
            }
        }];
    }
}

- (void) reportPlayingState:(AudioPlayState)state
{
    NSMutableArray *handlers = [self.playListeners objectForKey:self.audioURL.absoluteString];
    //Inform the handlers
    [handlers enumerateObjectsUsingBlock:^(AudioPlayHandler *handler, NSUInteger idx, BOOL *stop) {
        
        if ([handler.delegate respondsToSelector:@selector(player:statusDidChange:)]) {
            [handler.delegate player:self.audioPlayer statusDidChange:state];
        }
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.audioPlayer && self.audioPlayer == object && [keyPath isEqualToString:@"rate"]) {
        
        float newRate = [[change objectForKey:@"new"] floatValue];
        
        AudioPlayState state = newRate != 0 ? AudioPlayStatePlaying : AudioPlayStatePaused;
        
        [self reportPlayingState:state];
    }
}

#pragma mark AVPlayer
- (void) removeAVPlayer {
    
    [self removeTimeObserverFromPlayer];
    
    if (self.audioPlayer) {
        
        [self.audioPlayer removeObserver:self forKeyPath:@"rate"];
        self.audioPlayer = nil;
    }
}

- (BOOL) loadAVPlayer {
    
    AVAsset *asset = [AVAsset assetWithURL:self.audioURL];
    
    NSArray *audioTracks = asset ? [asset tracksWithMediaType:AVMediaTypeAudio] : nil;
    
    if (audioTracks && [audioTracks count] > 0) {
        
        self.audioPlayer = [[AVPlayer alloc] init];
        
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
        
        [self.audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
        
        [self addTimeObserverToPlayer];
        
        [self.audioPlayer addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
        
        return YES;
    }
    
    return NO;
}




@end
