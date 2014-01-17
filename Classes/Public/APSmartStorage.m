//
//  APSmartStorage.m
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/15/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "APSmartStorage.h"
#import "APNetworkLoader.h"
#import "APFileManager.h"
#import "APStoragePathHelper.h"
#import "NSThread+Block.h"

@interface APSmartStorage ()
{
    APNetworkLoader *networkLoader;
    APFileManager *fileManager;
}
@end

@implementation APSmartStorage

#pragma mark - life cycle

- (id)init
{
    NSURLSessionConfiguration *config = NSURLSessionConfiguration.defaultSessionConfiguration;
    return [self initWithCustomSessionConfiguration:config];
}

- (id)initWithCustomSessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    self = [super init];
    if (self)
    {
        networkLoader = [[APNetworkLoader alloc] initWithURLSessionConfiguration:configuration];
        fileManager = [[APFileManager alloc] init];
    }
    return self;
}

#pragma mark - public

- (void)loadObjectWithURL:(NSURL *)objectURL keepInMemory:(BOOL)keepInMemory
                 callback:(void (^)(id object, NSError *))callback
{
    __weak NSThread *weakThread = NSThread.currentThread;
    [self loadDataWithURL:objectURL callback:^(NSData *data, NSError *error)
    {
        [weakThread performBlockOnThread:^
        {
            callback ? callback(data, error) : nil;
        }];
    }];
}

- (void)reloadObjectWithURL:(NSURL *)objectURL keepInMemory:(BOOL)keepInMemory
                   callback:(void (^)(id object, NSError *))callback
{
}

- (void)removeObjectWithURL:(NSURL *)objectURL
{
    NSURL *fileURL = [APStoragePathHelper storageURLForNetworkURL:objectURL];
    [fileManager removeFileAtURL:fileURL];
}

- (void)removeAllObjects
{
    NSURL *directoryURL = [APStoragePathHelper storageDirectoryURL];
    [fileManager removeDirectoryAtURL:directoryURL];
}

#pragma mark - private

- (void)loadDataWithURL:(NSURL *)url callback:(void (^)(NSData *data, NSError *error))callback
{
    NSURL *localURL = [APStoragePathHelper storageURLForNetworkURL:url];
    if ([fileManager isFileExistsForURL:localURL])
    {
        [fileManager loadFileAtURL:localURL callback:callback];
    }
    else
    {
        [networkLoader loadObjectWithURL:url toFileURL:localURL callback:callback];
    }
}

@end
