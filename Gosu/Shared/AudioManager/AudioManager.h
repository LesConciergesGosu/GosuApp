//
//  AudioManager.h
//  Gosu
//
//  Created by dragon on 4/5/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, AudioPlayState) {
    AudioPlayStatePlaying = 0,
    AudioPlayStatePaused = 1,
    AudioPlayStateStopped = 2,
    AudioPlayStateFailed = 3
};

@class AudioManager;
@protocol AudioRecordDelegate <NSObject>
- (void)audioManager:(AudioManager *)manager didFinishWithSucess:(BOOL)success recordedPath:(NSString *)path duration:(NSTimeInterval)duration;
- (void)audioManager:(AudioManager *)manager UpdateRecordingTime:(NSTimeInterval)interval;

@end

@protocol AudioPlayDelegate <NSObject>
@optional
- (void) player:(AVPlayer *)player reportTime:(NSTimeInterval)time duration:(NSTimeInterval)duration;
- (void) player:(AVPlayer *)player statusDidChange:(AudioPlayState)state;

@end

@interface AudioManager : NSObject

#pragma mark Audio Recording

@property (weak) id<AudioRecordDelegate> recordingDelegate;

+ (AudioManager *)manager;
- (BOOL)startRecordingWithDelegate:(id<AudioRecordDelegate>)aDelegate;
- (void)stopRecording;
- (void)cancelRecording;

#pragma mark Audio Playing

+ (void) attachPlayListener:(id<AudioPlayDelegate>)listener toURL:(NSURL*)url;
+ (void) detachPlayListener:(id<AudioPlayDelegate>)listener;

- (void) stopPlayingAtURL:(NSURL *)url;
- (BOOL) playAudioAtURL:(NSURL *)url;
- (void) stopPlaying;

@end
