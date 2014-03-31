//
//  APNetworkStorage.m
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/17/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <APAsyncDictionary/APAsyncDictionary.h>
#import "APNetworkStorage.h"

@interface APNetworkStorage ()
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
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:nil
                                            delegateQueue:queue];
        _dictionary = [[APAsyncDictionary alloc] init];
    }
    return self;
}

#pragma mark - public

- (void)downloadURL:(NSURL *)url callback:(void (^)(NSString *path, NSError *error))callback
{
    __weak __typeof(self) weakSelf = self;
    NSString *key = url.absoluteString;
    NSURLSessionDownloadTask *task = [_session downloadTaskWithURL:url
                                                 completionHandler:^(NSURL *location,
                                                                     NSURLResponse *response,
                                                                     NSError *error)
    {
        [weakSelf.dictionary removeObjectForKey:key];
        callback ? callback(location.path, error) : nil;
    }];
    [self.dictionary setObject:task forKey:key];
    [task resume];
}

- (void)cancelDownloadURL:(NSURL *)url
{
    NSString *key = url.absoluteString;
    [self.dictionary objectForKey:key callback:^(id <NSCopying> key, id object)
    {
        NSURLSessionDownloadTask *task = object;
        [task cancel];
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

@end
