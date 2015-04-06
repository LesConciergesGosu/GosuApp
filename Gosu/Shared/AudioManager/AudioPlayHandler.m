//
//  AudioPlayHandler.m
//  Gosu
//
//  Created by dragon on 4/5/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "AudioPlayHandler.h"

@implementation AudioPlayHandler


+ (AudioPlayHandler*) handlerWithURL:(NSURL*)url delegate:(id<AudioPlayDelegate>)delegate
{
    AudioPlayHandler *handler = [AudioPlayHandler new];
    
    handler.url = url;
    handler.delegate = delegate;
    
    return handler;
}

@end
