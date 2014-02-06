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
#import "NSThread+Block.h"

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

- (void)loadObjectWithURL:(NSURL *)url callback:(void (^)(id object, NSError *))callback
{
    __weak __typeof(self) weakSelf = self;
    [self.taskManager taskWithURL:url block:callback callback:^(BOOL isShouldRunTask)
    {
        if (isShouldRunTask)
        {
            [weakSelf objectFromStorageWithURL:url callback:^(id object, NSError *error)
            {
                [weakSelf.taskManager finishTaskWithURL:url object:object error:error];
            }];
        }
    }];
}

- (void)reloadObjectWithURL:(NSURL *)url callback:(void (^)(id object, NSError *))callback
{
    [self objectFromNetworkWithURL:url callback:callback];
}

- (void)removeObjectWithURL:(NSURL *)objectURL
{
    [self.memoryStorage removeObjectForURL:objectURL];
}

- (void)removeAllObjects
{
    [self.memoryStorage removeAllObjects];
}

- (void)cleanObjectWithURL:(NSURL *)url
{
    [self.memoryStorage removeObjectForURL:url];
    [self.fileStorage removeFileForURL:url];
}

- (void)cleanAllObjects
{
    [self removeAllObjects];
    [self.fileStorage removeAllFiles];
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
        _networkStorage = [[APNetworkStorage alloc] initWithURLSessionConfiguration:self.sessionConfiguration];
    }
    return _networkStorage;
}

#pragma mark - private methods

- (void)objectFromStorageWithURL:(NSURL *)url callback:(void (^)(id object, NSError *error))callback
{
    __weak __typeof(self) weakSelf = self;
    [self objectFromMemoryWithURL:url callback:^(id object)
    {
        if (object)
        {
            callback(object, nil);
        }
        else
        {
            [weakSelf objectFromFileWithURL:url callback:callback];
        }
    }];
}

- (void)objectFromMemoryWithURL:(NSURL *)objectURL callback:(void (^)(id object))callback
{
    [self.memoryStorage objectWithURL:objectURL callback:callback];
}

- (void)objectFromFileWithURL:(NSURL *)url callback:(void (^)(id object, NSError *error))callback
{
    __weak __typeof(self) weakSelf = self;
    [self.fileStorage dataWithURL:url callback:^(NSData *data)
    {
        if (data)
        {
            id result = weakSelf.parsingBlock ? weakSelf.parsingBlock(data, url) : data;
            if (result)
            {
                [weakSelf.memoryStorage setObject:result forURL:url];
            }
            callback(result, nil);
        }
        else
        {
            [weakSelf objectFromNetworkWithURL:url callback:callback];
        }
    }];
}

- (void)objectFromNetworkWithURL:(NSURL *)url callback:(void (^)(id object, NSError *error))callback
{
    __weak NSThread *weakThread = NSThread.currentThread;
    __weak __typeof(self) weakSelf = self;
    [self.networkStorage downloadURL:url callback:^(NSString *path, NSError *error)
    {
        if (path && !error)
        {
            [weakSelf.fileStorage moveDataWithURL:url downloadedToPath:path];
        }
        [NSThread performOnThread:weakThread block:^
        {
            path && !error ? [weakSelf objectFromFileWithURL:url callback:callback] :
            callback(nil, error);
        }];
    }];
}

#if TARGET_OS_IPHONE
- (void)didReceiveMemoryWarning:(NSNotification *)notification
{
    [self.memoryStorage removeAllObjects];
    _memoryStorage = nil;
    _fileStorage = nil;
    _networkStorage = nil;
}
#endif

@end
