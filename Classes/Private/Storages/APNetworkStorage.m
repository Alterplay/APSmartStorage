//
//  APNetworkStorage.m
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/17/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <APAsyncDictionary/APAsyncDictionary.h>
#import "APNetworkStorage.h"
#import "APNetworkTask.h"

@interface APNetworkStorage () <NSURLSessionDownloadDelegate>
{
    NSURLSession *_session;
}
@property (nonatomic, readonly) APAsyncDictionary *dictionary;
@end

@implementation APNetworkStorage

#pragma mark - life cycle

- (id)init
{
    NSURLSessionConfiguration *config = NSURLSessionConfiguration.defaultSessionConfiguration;
    return [self initWithURLSessionConfiguration:config];
}

- (id)initWithURLSessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    self = [super init];
    if (self)
    {
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self
                                            delegateQueue:nil];
        _dictionary = [[APAsyncDictionary alloc] init];
    }
    return self;
}

#pragma mark - public

- (void)downloadURL:(NSURL *)url progress:(void (^)(NSUInteger percents))progress
         completion:(void (^)(NSString *path, NSError *error))completion
{
    NSString *key = url.absoluteString;
    APNetworkTask *task = [[APNetworkTask alloc] initWithDownloadTask:[_session downloadTaskWithURL:url]];
    [self.dictionary setObject:task forKey:key];
    task.progressBlock = progress;
    task.completionBlock = completion;
    [task start];
}

- (void)cancelDownloadURL:(NSURL *)url
{
    NSString *key = url.absoluteString;
    [self.dictionary objectForKey:key callback:^(id <NSCopying> key, APNetworkTask *networkTask)
    {
        [networkTask cancel];
    }];
    [self.dictionary removeObjectForKey:key];
}

- (void)cancelAllDownloads
{
    [self.dictionary allObjectsCallback:^(NSArray *objects)
    {
        [objects makeObjectsPerformSelector:@selector(cancel)];
    }];
    [self.dictionary removeAllObjects];
}

#pragma mark - URL session download delegate implementation

- (void)       URLSession:(NSURLSession *)session
             downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSString *key = downloadTask.originalRequest.URL.absoluteString;
    APNetworkTask *networkTask = [self.dictionary objectForKeySynchronously:key];
    if (networkTask.completionBlock)
    {
        networkTask.completionBlock(location.path, nil);
    }
    [self.dictionary removeObjectForKey:key];
}

- (void)  URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    if (error)
    {
        NSString *key = task.originalRequest.URL.absoluteString;
        APNetworkTask *networkTask = [self.dictionary objectForKeySynchronously:key];
        if (networkTask.completionBlock)
        {
            networkTask.completionBlock(nil, error);
        }
        [self.dictionary removeObjectForKey:key];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
             didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSString *key = downloadTask.originalRequest.URL.absoluteString;
    NSUInteger progress = 0;
    if (totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown)
    {
        CGFloat relation = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
        // we should end with 90% because we need to read data from file and parse it
        progress = (NSUInteger)(relation * 90.f);
    }
    APNetworkTask *networkTask = [self.dictionary objectForKeySynchronously:key];
    if (networkTask.progressBlock)
    {
        networkTask.progressBlock(progress);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    // does nothing
}

@end
