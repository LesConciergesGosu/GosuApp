//
//  GDownloadHandler.h
//  DownloadManager
//
//  Created by dragon on 4/5/2013.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDownloadManager.h"

@interface GDownloadHandler : NSObject

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) GDProgressBlock progressBlock;
@property (nonatomic, strong) GDCompletionBlock completionBlock;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) id<GDownloadManagerDelegate> delegate;

+ (GDownloadHandler*) downloadingHandlerWithURL:(NSURL*)url
                                   progressBlock:(GDProgressBlock)progressBlock
                                 completionBlock:(GDCompletionBlock)completionBlock
                                             tag:(NSInteger)tag;

+ (GDownloadHandler*) downloadingHandlerWithURL:(NSURL*)url
                                        delegate:(id<GDownloadManagerDelegate>)delegate;
@end