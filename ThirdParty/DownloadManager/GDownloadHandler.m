//
//  GDownloadHandler.m
//  DownloadManager
//
//  Created by dragon on 4/5/2013.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "GDownloadHandler.h"

@implementation GDownloadHandler

+ (GDownloadHandler*) downloadingHandlerWithURL:(NSURL*)url
                                   progressBlock:(GDProgressBlock)progressBlock
                                 completionBlock:(GDCompletionBlock)completionBlock
                                             tag:(NSInteger)tag
{
    GDownloadHandler *handler = [GDownloadHandler new];
    handler.url = url;
    handler.tag = tag;
    handler.progressBlock = progressBlock;
    handler.completionBlock = completionBlock;
    
    return handler;
}

+ (GDownloadHandler*) downloadingHandlerWithURL:(NSURL*)url
                                        delegate:(id<GDownloadManagerDelegate>)delegate
{
    GDownloadHandler *handler = [GDownloadHandler new];
    
    handler.url = url;
    handler.delegate = delegate;
    
    return handler;
}

@end