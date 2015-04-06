//
//  IADownloadManager.m
//  DownloadManager
//
//  Created by dragon on 4/5/2013.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "GDownloadManager.h"
#import "GDownloadHandler.h"
#import "GDownloadOperation.h"
#import <AFNetworking/AFNetworking.h>

@interface GDownloadManager()

@property (nonatomic, strong) NSMutableDictionary *downloadOperations;
@property (nonatomic, strong) NSMutableDictionary *downloadHandlers;

- (void)removeHandlerWithTag:(NSInteger)tag;

@end

@implementation GDownloadManager

#pragma mark Initialization
#pragma mark -

+ (GDownloadManager*) instance
{
	static id instance;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[[self class] alloc] init];
	});
	
	return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.downloadOperations = [NSMutableDictionary new];
        self.downloadHandlers = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark Global Blocks
#pragma mark -

void (^globalProgressBlock)(float progress, NSURL *url, GDownloadManager* self) =
^(float progress, NSURL *url, GDownloadManager* self)
{
    NSMutableArray *handlers = [self.downloadHandlers objectForKey:url];
    //Inform the handlers
    [handlers enumerateObjectsUsingBlock:^(GDownloadHandler *handler, NSUInteger idx, BOOL *stop) {
        
        if(handler.progressBlock)
            handler.progressBlock(progress, url);
        
        if([handler.delegate respondsToSelector:@selector(downloadManagerDidProgress:)])
            [handler.delegate downloadManagerDidProgress:progress];
        
    }];
};

void (^globalCompletionBlock)(BOOL success, id response, NSURL *url, GDownloadManager* self) =
^(BOOL success, id response, NSURL *url, GDownloadManager* self)
{
    NSMutableArray *handlers = [self.downloadHandlers objectForKey:url];
    //Inform the handlers
    [handlers enumerateObjectsUsingBlock:^(GDownloadHandler *handler, NSUInteger idx, BOOL *stop) {
    
        if(handler.completionBlock)
            handler.completionBlock(success, response);
        
        if([handler.delegate respondsToSelector:@selector(downloadManagerDidFinish:response:)])
            [handler.delegate downloadManagerDidFinish:success response:response];
        
    }];
    
    //Remove the download handlers
    [self.downloadHandlers removeObjectForKey:url];
    
    //Remove the download operation
    [self.downloadOperations removeObjectForKey:url];
};

#pragma mark Entry Point
#pragma mark -

- (void) downloadImageWithURL:(NSURL*)url
                    useCache:(BOOL)useCache
{
    //Create a new download operation if it does not already Exist
    [self startImageDownloadOperation:url useCache:useCache];
}


- (void) downloadItemWithURL:(NSURL*)url
                    useCache:(BOOL)useCache
{
    //Create a new download operation if it does not already Exist
    [self startDownloadOperation:url useCache:useCache];
}

- (void) attachNewHandlerWithListener:(id<GDownloadManagerDelegate>)listener
                                toURL:(NSURL*)url
{
    //We should remove the old handler
    //Allow only 1 delegate to listen ot a set of URLs, maybe in the future we can have 1 delegate listening to more than a set of urls
    [self removeHandlerWithListener:listener];
    
    NSMutableArray *handlers = [self.downloadHandlers objectForKey:url];
    
    if (!handlers)
        handlers = [NSMutableArray new];
    
    GDownloadHandler *handler = [GDownloadHandler downloadingHandlerWithURL:url
                                                                     delegate:listener];
    
    
    [handlers addObject:handler];
    [self.downloadHandlers setObject:handlers forKey:url];
}

- (void) attachNewHandlerWithProgressBlock:(GDProgressBlock)progressBlock
                           completionBlock:(GDCompletionBlock)completionBlock
                                       tag:(NSInteger)tag
                                     toURL:(NSURL*)url
{
    //unlink the tag from the urls
    [self removeHandlerWithTag:tag];
    
    //Add the new handler
    NSMutableArray *handlers = [self.downloadHandlers objectForKey:url];
    if (!handlers)
        handlers = [NSMutableArray new];
    
    GDownloadHandler *handler = [GDownloadHandler downloadingHandlerWithURL:url
                                                                progressBlock:progressBlock
                                                              completionBlock:completionBlock
                                                                          tag:tag];
    
    
    [handlers addObject:handler];

    if (handlers.count == 3) {
        
    }
    [self.downloadHandlers setObject:handlers forKey:url];
}


#pragma mark Downloading
#pragma mark -

- (void)startDownloadOperation:(NSURL*)url
                      useCache:(BOOL)useCache
{
    if([self isDownloadingItemWithURL:url])
        return;
    
    GDownloadOperation *downloadingOperation = [GDownloadOperation
                                                 downloadingOperationWithURL:url
                                                 useCache:useCache
                                                 progressBlock:^(float progress, id x) {
                                                     
                                                     globalProgressBlock(progress, url, self);
                                                     
                                                 }
                                                 completionBlock:^(BOOL success, id response) {
                                                     
                                                     globalCompletionBlock(success, response, url, self);
                                                     
                                                 }];
    
    if(downloadingOperation)
    {
        [downloadingOperation start];
    
        //Add the new operation
        [self.downloadOperations setObject:downloadingOperation forKey:url];
    }
}

- (void)startImageDownloadOperation:(NSURL*)url
                      useCache:(BOOL)useCache
{
    if([self isDownloadingItemWithURL:url])
        return;
    
    AFImageResponseSerializer *serializer = [[AFImageResponseSerializer alloc] init];
    GDownloadOperation *downloadingOperation = [GDownloadOperation
                                                downloadingOperationWithURL:url
                                                serializer:serializer
                                                useCache:useCache
                                                progressBlock:^(float progress, id x) {
                                                    
                                                    globalProgressBlock(progress, url, self);
                                                    
                                                }
                                                completionBlock:^(BOOL success, id response) {
                                                    
                                                    globalCompletionBlock(success, response, url, self);
                                                    
                                                }];
    
    if(downloadingOperation)
    {
        [downloadingOperation start];
        
        //Add the new operation
        [self.downloadOperations setObject:downloadingOperation forKey:url];
    }
}

- (BOOL) isDownloadingItemWithURL:(NSURL*)url
{
    return [self.downloadOperations objectForKey:url] != nil;
}

#pragma mark IADownloadHandlers and IADownloadOperation Helpers
#pragma mark -

- (void)removeHandlerWithURL:(NSURL*)url tag:(int)tag
{
    NSMutableArray *handlers = [self.downloadHandlers objectForKey:url];
    if (handlers)
    {
        for (NSInteger i = handlers.count - 1; i >= 0; i-- )
        {
            GDownloadHandler *handler = handlers[i];
            
            if (handler.tag == tag)
            {
                [handlers removeObject:handler];
            }
        }
    }
}

- (void)removeHandlerWithURL:(NSURL*)url listener:(id)listener
{
    NSMutableArray *handlers = [self.downloadHandlers objectForKey:url];
    if (handlers)
    {
        for (NSInteger i = handlers.count - 1; i >= 0; i-- )
        {
            GDownloadHandler *handler = handlers[i];
            
            if (handler.delegate == listener)
            {
                [handlers removeObject:handler];
            }
        }
    }
}

- (void)removeHandlerWithTag:(NSInteger)tag
{
    for (NSInteger i = self.downloadHandlers.allKeys.count - 1; i >= 0; i-- )
    {
        id key = self.downloadHandlers.allKeys[i];
        NSMutableArray *array = [self.downloadHandlers objectForKey:key];
        
        for (NSInteger j = array.count - 1; j >= 0; j-- )
        {
            GDownloadHandler *handler = array[j];
            if (handler.tag == tag)
            {
                [array removeObject:handler];
            }
        }
    }
}

- (void)removeHandlerWithListener:(id)listener
{
    for (NSInteger i = self.downloadHandlers.allKeys.count - 1; i >= 0; i-- )
    {
        id key = self.downloadHandlers.allKeys[i];
        NSMutableArray *array = [self.downloadHandlers objectForKey:key];
        
        for (NSInteger j = array.count - 1; j >= 0; j-- )
        {
            GDownloadHandler *handler = array[j];
            if (handler.delegate == listener)
            {
                [array removeObject:handler];
            }
        }
    }
}


#pragma mark Class Interface Memebers
#pragma mark -

+ (void) downloadImageWithURL:(NSURL*)url
                     useCache:(BOOL)useCache
{
    [[self instance] downloadImageWithURL:url useCache:useCache];
}

+ (void) downloadItemWithURL:(NSURL*)url
                    useCache:(BOOL)useCache
{
    [[self instance] downloadItemWithURL:url
                                useCache:useCache];
}

+ (void) attachListener:(id<GDownloadManagerDelegate>)listener toURL:(NSURL*)url
{
    [[self instance] attachNewHandlerWithListener:listener toURL:url];
}

+ (void) detachListener:(id<GDownloadManagerDelegate>)listener;
{
    [[self instance] removeHandlerWithListener:listener];
}

+ (void) attachListenerWithObject:(id)object
                    progressBlock:(GDProgressBlock)progressBlock
                  completionBlock:(GDCompletionBlock)completionBlock
                            toURL:(NSURL*)url

{
    [[self instance] attachNewHandlerWithProgressBlock:progressBlock
                                       completionBlock:completionBlock
                                                   tag:object ? (int)object : NSNotFound
                                                 toURL:url];
}

+ (void) detachObjectFromListening:(id)object
{
    [[self instance] removeHandlerWithTag:(int)object];
}

+ (BOOL) isDownloadingItemWithURL:(NSURL*)url
{
    return [[self instance] isDownloadingItemWithURL:url];
}

+ (void) stopDownloadingItemWithURL:(NSURL*)url
                             andTag:(int)tag
{
    [self.instance removeHandlerWithURL:url tag:tag];
    
    NSArray *handlers = [[self instance].downloadHandlers objectForKey:url];
    if (handlers.count == 0) {
        [self stopDownloadingItemWithURL:url];
    }
}

+ (void) stopDownloadingItemWithURL:(NSURL*)url
{
    [[[self instance].downloadOperations objectForKey:url] stop];
}

+ (NSString *)cachedPathForURL:(NSURL *)url {
    return [GDownloadOperation cachedPathForKey:url];
}

+ (BOOL) hasDiskCacheForURL:(NSURL *)url {
    return [GDownloadOperation hasDiskCacheForURL:url];
}

@end
