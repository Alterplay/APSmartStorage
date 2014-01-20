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
    NSUInteger maxObjectCount;
}
@property (nonatomic, readonly) NSURLSessionConfiguration *sessionConfiguration;
@property (nonatomic, readonly) APMemoryStorage *memoryStorage;
@property (nonatomic, readonly) APFileManager *fileManager;
@property (nonatomic, readonly) APNetworkLoader *networkLoader;
@end

@implementation APSmartStorage

@synthesize sessionConfiguration = _sessionConfiguration, networkLoader = _networkLoader,
fileManager = _fileManager, memoryStorage = _memoryStorage;

#pragma mark - life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
        [center addObserver:self selector:@selector(didReceiveMemoryWarning:)
                       name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (id)initWithCustomSessionConfiguration:(NSURLSessionConfiguration *)configuration
                          maxObjectCount:(NSUInteger)count
{
    self = [self init];
    if (self)
    {
        maxObjectCount = count;
        _sessionConfiguration = configuration;
    }
    return self;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
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
            [weakSelf parseDataWithNetworkURL:objectURL keepInMemory:keepInMemory skipFileStorage:NO
                                     callback:callback];
        }
    }];
}

- (void)reloadObjectWithURL:(NSURL *)objectURL keepInMemory:(BOOL)keepInMemory
                   callback:(void (^)(id object, NSError *))callback
{
    [self parseDataWithNetworkURL:objectURL keepInMemory:keepInMemory skipFileStorage:YES
                         callback:callback];
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
    [self.fileManager removeFileAtURL:fileURL];
}

- (void)cleanAllObjects
{
    NSURL *directoryURL = [APStoragePathHelper storageDirectoryURL];
    [self.fileManager removeDirectoryAtURL:directoryURL];
}

#pragma mark - properties

- (NSURLSessionConfiguration *)sessionConfiguration
{
    return _sessionConfiguration ?: [NSURLSessionConfiguration defaultSessionConfiguration];
}

- (APMemoryStorage *)memoryStorage
{
    if (!_memoryStorage)
    {
        _memoryStorage = [[APMemoryStorage alloc] initWithMaxObjectCount:maxObjectCount];
    }
    return _memoryStorage;
}

- (APFileManager *)fileManager
{
    if (!_fileManager)
    {
        _fileManager = [[APFileManager alloc] init];
    }
    return _fileManager;
}

- (APNetworkLoader *)networkLoader
{
    if (!_networkLoader)
    {
        _networkLoader = [[APNetworkLoader alloc] initWithURLSessionConfiguration:self.sessionConfiguration];
    }
    return _networkLoader;
}

#pragma mark - private

- (void)parseDataWithNetworkURL:(NSURL *)objectURL keepInMemory:(BOOL)keepInMemory
                skipFileStorage:(BOOL)isSkipFileStorage callback:(void (^)(id, NSError *))callback
{
    NSURL *localURL = [APStoragePathHelper storageURLForNetworkURL:objectURL];
    __weak __typeof(self) weakSelf = self;
    __weak NSThread *weakThread = NSThread.currentThread;
    [self loadDataWithNetworkURL:objectURL skipFileStorage:isSkipFileStorage
                        callback:^(NSData *data, NSError *error)
    {
        NSObject *object = weakSelf.parsingBlock ?
                           weakSelf.parsingBlock(data, objectURL) : data;
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

- (void)loadDataWithNetworkURL:(NSURL *)networkURL skipFileStorage:(BOOL)isSkipFileStorage
                      callback:(void (^)(NSData *data, NSError *error))callback
{
    NSURL *localURL = [APStoragePathHelper storageURLForNetworkURL:networkURL];
    // object found at file
    if (!isSkipFileStorage && [self.fileManager isFileExistsForURL:localURL])
    {
        [self.fileManager loadFileAtURL:localURL callback:callback];
    }
    // load object from network
    else
    {
        [self.networkLoader loadObjectWithURL:networkURL toFileURL:localURL callback:callback];
    }
}

- (void)didReceiveMemoryWarning:(NSNotification *)notification
{
    [self.memoryStorage removeAllObjects];
    _memoryStorage = nil;
    _fileManager = nil;
    _networkLoader = nil;
}

@end
