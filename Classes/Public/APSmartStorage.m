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
#import "APMemoryStorage.h"
#import "APStoragePathHelper.h"
#import "NSThread+Block.h"

@interface APSmartStorage ()
{
    APNetworkLoader *networkLoader;
    APFileManager *fileManager;
}
@property (nonatomic, readonly) APMemoryStorage *memoryStorage;
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
        _memoryStorage = [[APMemoryStorage alloc] initWithMaxObjectCount:0];
    }
    return self;
}

#pragma mark - public

- (void)loadObjectWithURL:(NSURL *)objectURL keepInMemory:(BOOL)keepInMemory
                 callback:(void (^)(id object, NSError *))callback
{
    NSURL *localURL = [APStoragePathHelper storageURLForNetworkURL:objectURL];
    __weak __typeof(self) weakSelf = self;
    [self.memoryStorage objectForLocalURL:localURL callback:^(id object)
    {
        // object found in memory storage
        if (object)
        {
            callback ? callback(object, nil) : nil;
        }
        // load object from file or network
        else
        {
            [weakSelf reloadObjectWithURL:objectURL keepInMemory:keepInMemory callback:callback];
        }
    }];
}

- (void)reloadObjectWithURL:(NSURL *)objectURL keepInMemory:(BOOL)keepInMemory
                   callback:(void (^)(id object, NSError *))callback
{
    NSURL *localURL = [APStoragePathHelper storageURLForNetworkURL:objectURL];
    __weak __typeof(self) weakSelf = self;
    __weak NSThread *weakThread = NSThread.currentThread;
    [self loadDataWithNetworkURL:objectURL localURL:localURL
                        callback:^(NSData *data, NSError *error)
    {
        NSObject *object = data;
        // save object to memory if it necessary
        if (keepInMemory && object && !error)
        {
            [weakSelf.memoryStorage setObject:object forLocalURL:localURL];
        }
        // perform callback on caller thread
        [weakThread performBlockOnThread:^
        {
            callback ? callback(object, error) : nil;
        }];
    }];
}

- (void)removeObjectWithURL:(NSURL *)objectURL
{
    NSURL *fileURL = [APStoragePathHelper storageURLForNetworkURL:objectURL];
    [self.memoryStorage removeObjectForLocalURL:fileURL];
}

- (void)removeAllObjects
{
    [self.memoryStorage removeAllObjects];
}

- (void)cleanObjectWithURL:(NSURL *)objectURL
{
    NSURL *fileURL = [APStoragePathHelper storageURLForNetworkURL:objectURL];
    [self.memoryStorage removeObjectForLocalURL:fileURL];
    [fileManager removeFileAtURL:fileURL];
}

- (void)cleanAllObjects
{
    NSURL *directoryURL = [APStoragePathHelper storageDirectoryURL];
    [fileManager removeDirectoryAtURL:directoryURL];
}

#pragma mark - private

- (void)loadDataWithNetworkURL:(NSURL *)networkURL localURL:(NSURL *)localURL
                      callback:(void (^)(NSData *data, NSError *error))callback
{
    // object found at file
    if ([fileManager isFileExistsForURL:localURL])
    {
        [fileManager loadFileAtURL:localURL callback:callback];
    }
    // load object from network
    else
    {
        [networkLoader loadObjectWithURL:networkURL toFileURL:localURL callback:callback];
    }
}

@end
