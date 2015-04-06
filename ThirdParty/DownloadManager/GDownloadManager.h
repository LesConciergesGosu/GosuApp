//
//  GDownloadManager.h
//  DownloadManager
//
//  Created by dragon on 4/5/2013.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^GDProgressBlock)(float progress, NSURL *url);
typedef void (^GDCompletionBlock)(BOOL success, id response);

@protocol GDownloadManagerDelegate <NSObject>
- (void) downloadManagerDidProgress:(float)progress;
- (void) downloadManagerDidFinish:(BOOL)success response:(id)response;
@end

@interface GDownloadManager : NSObject

+ (void) downloadImageWithURL:(NSURL*)url
                    useCache:(BOOL)useCache;

//Start the download request for a URL, note that the same URL will never be downloaded twice
+ (void) downloadItemWithURL:(NSURL*)url
                    useCache:(BOOL)useCache;

//Delegate based events
// 1 url download operation can have multiple listeners
// But 1 listener cannot listen to 1 url download operation
+ (void) attachListener:(id<GDownloadManagerDelegate>)listener toURL:(NSURL*)url;

//Detach the listener from listening to more events,
//Please note that the url will still download
+ (void) detachListener:(id<GDownloadManagerDelegate>)listener;

//Block based events
//object param must be equal to self to ensure that 1 object can listen to only 1 download operation
+ (void) attachListenerWithObject:(id)object
                    progressBlock:(GDProgressBlock)progressBlock
                  completionBlock:(GDCompletionBlock)completionBlock
                            toURL:(NSURL*)url;
//Remove listener
+ (void) detachObjectFromListening:(id)object;

+ (BOOL) isDownloadingItemWithURL:(NSURL*)url;
+ (void) stopDownloadingItemWithURL:(NSURL*)url;
+ (NSString *)cachedPathForURL:(NSURL *)url;
+ (BOOL) hasDiskCacheForURL:(NSURL *)url;

@end
