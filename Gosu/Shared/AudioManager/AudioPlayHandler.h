//
//  AudioPlayHandler.h
//  Gosu
//
//  Created by dragon on 4/5/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioManager.h"

@interface AudioPlayHandler : NSObject
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) id<AudioPlayDelegate> delegate;

+ (AudioPlayHandler*) handlerWithURL:(NSURL*)url delegate:(id<AudioPlayDelegate>)delegate;
@end
