//
//  GDownloadOperation.h
//  DownloadManager
//
//  Created by dragon on 4/5/2013.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDownloadManager.h"

@class AFHTTPRequestOperation;
@class AFHTTPResponseSerializer;
@interface GDownloadOperation : NSOperation
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) AFHTTPRequestOperation *operation;

+ (GDownloadOperation*) downloadingOperationWithURL:(NSURL*)url
                                         serializer:(AFHTTPResponseSerializer *)serializer
                                           useCache:(BOOL)useCache
                                      progressBlock:(GDProgressBlock)progressBlock
                                    completionBlock:(GDCompletionBlock)completionBlock;

+ (GDownloadOperation*) downloadingOperationWithURL:(NSURL*)url
                                           useCache:(BOOL)useCache
                                      progressBlock:(GDProgressBlock)progressBlock
                                    completionBlock:(GDCompletionBlock)completionBlock;
+ (NSString*)cacheKeyForUrl:(NSURL*)url;
+ (NSString *)cachedPathForKey:(NSURL *)url;
+ (BOOL) hasDiskCacheForURL:(NSURL *)url;
- (void)start;
- (void)stop;

@end
