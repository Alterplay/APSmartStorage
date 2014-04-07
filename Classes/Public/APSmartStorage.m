//
//  APSmartStorage.m
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/15/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "APSmartStorage.h"
#import "APTaskManager.h"
#import "APNetworkStorage.h"
#import "APFileStorage.h"
#import "APMemoryStorage.h"

@interface APSmartStorage ()

@property (nonatomic, readonly) APTaskManager *taskManager;
@property (nonatomic, readonly) APMemoryStorage *memoryStorage;
@property (nonatomic, readonly) APFileStorage *fileStorage;
@property (nonatomic, readonly) APNetworkStorage *networkStorage;
@end

@implementation APSmartStorage

@synthesize sessionConfiguration = _sessionConfiguration, networkStorage = _networkStorage,
fileStorage = _fileStorage, memoryStorage = _memoryStorage;

#pragma mark - life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        _taskManager = [[APTaskManager alloc] init];
#if TARGET_OS_IPHONE
        NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
        [center addObserver:self selector:@selector(didReceiveMemoryWarning:)
                       name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
#endif
    }
    return self;
}

- (void)dealloc
{
#if TARGET_OS_IPHONE
    [NSNotificationCenter.defaultCenter removeObserver:self];
#endif
}

#pragma mark - singleton

+ (instancetype)sharedInstance
{
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - public

- (void)loadObjectWithURL:(NSURL *)url completion:(void (^)(id object, NSError *))completion
{
    [self loadObjectWithURL:url storeInMemory:YES completion:completion];
}

- (void)loadObjectWithURL:(NSURL *)url storeInMemory:(BOOL)storeInMemory
               completion:(void (^)(id object, NSError *))completion
{
    [self loadObjectWithURL:url storeInMemory:storeInMemory progress:nil
                 completion:completion];
}

- (void)loadObjectWithURL:(NSURL *)url storeInMemory:(BOOL)storeInMemory
                 progress:(void (^)(NSUInteger percents))progress
               completion:(void (^)(id object, NSError *))completion
{
    APStorageTask *task = [self.taskManager addTaskWithURL:url storeInMemory:storeInMemory
                                           completionBlock:completion progressBlock:progress];
    if (task.isShouldRun)
    {
        __weak __typeof (self) weakSelf = self;
        [self storageObjectForTask:task progress:^(NSUInteger percents)
        {
            [weakSelf.taskManager progressTaskWithURL:url percents:percents];
        }               completion:^(id object, NSError *error)
        {
            [weakSelf.taskManager finishTaskWithURL:url object:object error:error];
        }];
    }
}

- (void)reloadObjectWithURL:(NSURL *)url completion:(void (^)(id object, NSError *))completion
{
    [self reloadObjectWithURL:url storeInMemory:YES completion:completion];
}

- (void)reloadObjectWithURL:(NSURL *)url storeInMemory:(BOOL)storeInMemory
                 completion:(void (^)(id object, NSError *))completion
{
    [self reloadObjectWithURL:url storeInMemory:storeInMemory progress:nil
                   completion:completion];
}

- (void)reloadObjectWithURL:(NSURL *)url storeInMemory:(BOOL)storeInMemory
                   progress:(void (^)(NSUInteger percents))progress
                 completion:(void (^)(id object, NSError *))completion
{
    [self removeObjectWithURLFromStorage:url];
    [self loadObjectWithURL:url storeInMemory:storeInMemory progress:progress completion:completion];
}

- (void)removeObjectWithURLFromMemory:(NSURL *)url
{
    [self.memoryStorage removeObjectForURL:url];
}

- (void)removeObjectWithURLFromStorage:(NSURL *)url
{
    [self.networkStorage cancelDownloadURL:url];
    [self.fileStorage removeFileForURL:url];
    [self.memoryStorage removeObjectForURL:url];
    [self.taskManager cancelTaskWithURL:url];
}

- (void)removeAllFromMemory
{
    [self.memoryStorage removeAllObjects];
}

- (void)removeAllFromStorage
{
    [self.networkStorage cancelAllDownloads];
    [self.fileStorage removeAllFiles];
    [self removeAllFromMemory];
    [self.taskManager cancelAllTasks];
}

#pragma mark - public properties

- (void)setMaxObjectCount:(NSUInteger)maxObjectCount
{
    _maxObjectCount = maxObjectCount;
    self.memoryStorage.maxCount = maxObjectCount;
}

- (NSURLSessionConfiguration *)sessionConfiguration
{
    return _sessionConfiguration ?: [NSURLSessionConfiguration defaultSessionConfiguration];
}

- (void)setSessionConfiguration:(NSURLSessionConfiguration *)sessionConfiguration
{
    if (_sessionConfiguration != sessionConfiguration)
    {
        _sessionConfiguration = sessionConfiguration;
        _networkStorage = nil;
    }
}

#pragma mark - private properties

- (APMemoryStorage *)memoryStorage
{
    if (!_memoryStorage)
    {
        _memoryStorage = [[APMemoryStorage alloc] initWithMaxObjectCount:self.maxObjectCount];
    }
    return _memoryStorage;
}

- (APFileStorage *)fileStorage
{
    if (!_fileStorage)
    {
        _fileStorage = [[APFileStorage alloc] init];
    }
    return _fileStorage;
}

- (APNetworkStorage *)networkStorage
{
    if (!_networkStorage)
    {
        _networkStorage = [[APNetworkStorage alloc]
                                             initWithURLSessionConfiguration:self.sessionConfiguration];
    }
    return _networkStorage;
}

#pragma mark - private methods

- (void)storageObjectForTask:(APStorageTask *)task progress:(void (^)(NSUInteger percents))progress
                  completion:(void (^)(id object, NSError *error))completion
{
    __weak __typeof (self) weakSelf = self;
    [self memoryObjectForTask:task completion:^(id object)
    {
        object ? completion(object, nil) :
        [weakSelf fileObjectForTask:task progress:progress completion:completion];
    }];
}

- (void)memoryObjectForTask:(APStorageTask *)task completion:(void (^)(id object))completion
{
    completion([self.memoryStorage objectWithURL:task.url]);
}

- (void)fileObjectForTask:(APStorageTask *)task progress:(void (^)(NSUInteger percents))progress
               completion:(void (^)(id object, NSError *error))completion
{
    NSURL *url = task.url;
    BOOL shouldStoreInMemory = task.storeInMemory;
    __weak __typeof (self) weakSelf = self;
    [self.fileStorage dataWithURL:url progress:progress completion:^(NSData *data)
    {
        // performed in background thread!
        if (data)
        {
            id result = weakSelf.parsingBlock ? weakSelf.parsingBlock(data, url) : data;
            if (shouldStoreInMemory)
            {
                [weakSelf.memoryStorage setObject:result forURL:url];
            }
            completion(result, nil);
        }
        // if no data then load from network
        else
        {
            [weakSelf networkObjectForTask:task progress:progress completion:completion];
        }
    }];
}

- (void)networkObjectForTask:(APStorageTask *)task progress:(void (^)(NSUInteger percents))progress
                  completion:(void (^)(id object, NSError *error))completion
{
    NSURL *url = task.url;
    __weak __typeof (self) weakSelf = self;
    [self.networkStorage downloadURL:url progress:progress
                          completion:^(NSString *path, NSError *networkError)
    {
        // performed in background thread!
        NSError *fileError = nil;
        // file has been downloaded and moved
        if (path && !networkError &&
            [weakSelf.fileStorage moveDataWithURL:url downloadedToPath:path error:&fileError])
        {
            [weakSelf fileObjectForTask:task progress:progress completion:completion];
        }
        else
        {
            completion(nil, networkError ?: fileError);
        }
    }];
}

#if TARGET_OS_IPHONE
- (void)didReceiveMemoryWarning:(NSNotification *)notification
{
    [self.networkStorage cancelAllDownloads];
    [self.memoryStorage removeAllObjects];
    [self.taskManager cancelAllTasks];
    _memoryStorage = nil;
    _fileStorage = nil;
    _networkStorage = nil;
}
#endif

@end
