//
//  IADownloadOperation.m
//  DownloadManager
//
//  Created by dragon on 4/5/2013.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "GDownloadOperation.h"
#import "AFNetworking.h"
#import "EGOCache.h"
#import <CommonCrypto/CommonDigest.h>

@interface GDownloadOperation()
{
    BOOL executing;
    BOOL cancelled;
    BOOL finished;
}
@property (nonatomic) BOOL isNSData;
@end

@implementation GDownloadOperation

+ (GDownloadOperation*) downloadingOperationWithURL:(NSURL*)url
                                         serializer:(AFHTTPResponseSerializer *)serializer
                                           useCache:(BOOL)useCache
                                      progressBlock:(GDProgressBlock)progressBlock
                                    completionBlock:(GDCompletionBlock)completionBlock
{
    GDownloadOperation *op = [GDownloadOperation new];
    op.url = url;
    
    op.isNSData = YES;
    if ([serializer isKindOfClass:[AFImageResponseSerializer class]])
        op.isNSData = NO;
    
    if(useCache && [self hasCacheForURL:url])
    {
        [op fetchItemFromCacheForURL:url progressBlock:progressBlock
                     completionBlock:completionBlock];
        return nil;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setResponseSerializer:serializer];
    op.operation = operation;
    
    __weak GDownloadOperation *weakOp = op;
    [op.operation
     setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         if ([responseObject isKindOfClass:[NSData class]])
             [GDownloadOperation setCacheWithData:responseObject url:url];
         else
             [GDownloadOperation setCacheObject:responseObject url:url];
         __strong GDownloadOperation *StrongOp = weakOp;
         [StrongOp finish];
         completionBlock(YES, responseObject);
         
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         __strong GDownloadOperation *StrongOp = weakOp;
         completionBlock(NO, nil);
         [StrongOp finish];
     }];
    
    [op.operation setDownloadProgressBlock:^(NSUInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
        float progress;
        
        if (totalBytesExpectedToRead == -1)
        {
            progress = -32;
        }
        else
        {
            progress = (double)totalBytesRead / (double)totalBytesExpectedToRead;
        }
        
        progressBlock(progress, url);
    }];
    
    return op;
}


+ (GDownloadOperation*) downloadingOperationWithURL:(NSURL*)url
                                           useCache:(BOOL)useCache
                                      progressBlock:(GDProgressBlock)progressBlock
                                    completionBlock:(GDCompletionBlock)completionBlock
{
    GDownloadOperation *op = [GDownloadOperation new];
    op.url = url;
    op.isNSData = YES;
 
    if(useCache && [self hasCacheForURL:url])
    {
        [op fetchItemFromCacheForURL:url progressBlock:progressBlock
                       completionBlock:completionBlock];
        return nil;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.operation = operation;
    
    __weak GDownloadOperation *weakOp = op;
    [op.operation
     setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         if ([responseObject isKindOfClass:[NSData class]])
             [GDownloadOperation setCacheWithData:responseObject url:url];
         else
             [GDownloadOperation setCacheObject:responseObject url:url];
         __strong GDownloadOperation *StrongOp = weakOp;
         [StrongOp finish];
         completionBlock(YES, responseObject);
         
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         __strong GDownloadOperation *StrongOp = weakOp;
         completionBlock(NO, nil);
         [StrongOp finish];
     }];
    
    [op.operation setDownloadProgressBlock:^(NSUInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
        float progress;
        
        if (totalBytesExpectedToRead == -1)
        {
            progress = -32;
        }
        else
        {
            progress = (double)totalBytesRead / (double)totalBytesExpectedToRead;
        }
        
        progressBlock(progress, url);
    }];
    
    return op;
}

- (void)start
{
    NSLog(@"opeartion for <%@> started.", _url);
    
    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self.operation start];
}

- (void)finish
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

+ (BOOL)hasCacheForURL:(NSURL*)url
{
    NSString *encodeKey = [self cacheKeyForUrl:url];
    return [[EGOCache globalCache] hasCacheForKey:encodeKey];
}

- (void)fetchItemFromCacheForURL:(NSURL*)url
                   progressBlock:(GDProgressBlock)progressBlock
                 completionBlock:(GDCompletionBlock)completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *encodeKey = [GDownloadOperation cacheKeyForUrl:url];
        
        id object = self.isNSData ? [[EGOCache globalCache] dataForKey:encodeKey] :
            [[EGOCache globalCache] objectForKey:encodeKey];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            progressBlock(1, url);
            completionBlock(YES, object);
            
            [self finish];
            
        });
    });
}

+ (void)setCacheObject:(id)object url:(NSURL*)url
{
    NSString *encodeKey = [self cacheKeyForUrl:url];
    [[EGOCache globalCache] setObject:object forKey:encodeKey];
}

+ (void)setCacheWithData:(NSData*)data
                     url:(NSURL*)url
{
    NSString *encodeKey = [self cacheKeyForUrl:url];
    [[EGOCache globalCache] setData:data forKey:encodeKey];
}

+ (NSString*)cacheKeyForUrl:(NSURL*)url
{
    NSString *key = url.absoluteString;
    NSString *ext = [url.absoluteString pathExtension];
    const char *str = [key UTF8String];
    unsigned char r[15];
    CC_MD5(str, (uint32_t)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    if (ext)
        filename = [filename stringByAppendingPathExtension:ext];
    
    return filename;
}

+ (NSString *)cachedPathForKey:(NSURL *)url {
    
    NSString *encodeKey = [self cacheKeyForUrl:url];
    
    return [[EGOCache globalCache] localPathForKey:encodeKey];
}

+ (BOOL) hasDiskCacheForURL:(NSURL *)url {
    NSString *encodeKey = [self cacheKeyForUrl:url];
    
    return [[EGOCache globalCache] hasCacheForKey:encodeKey];
}

- (void)startOperation
{
    [self.operation start];
    executing = YES;
}

- (void)stop
{
    [self.operation cancel];
    cancelled = YES;
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return executing;
}

- (BOOL)isCancelled
{
    return cancelled;
}

- (BOOL)isFinished
{
    return finished;
}

@end
