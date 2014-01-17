//
//  APFileManager.m
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/16/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "APFileManager.h"
#import "NSThread+Block.h"
#import "NSFileManager+Storage.h"

@interface APFileManager ()
@property (nonatomic, readonly) NSMutableDictionary *queues;
@end

@implementation APFileManager

#pragma mark - life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        _queues = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - public

- (BOOL)isFileExistsForURL:(NSURL *)fileURL
{
    return [NSFileManager.defaultManager fileExistsAtPath:fileURL.path];
}

- (void)loadFileAtURL:(NSURL *)fileURL callback:(void (^)(NSData *data, NSError *error))callback
{
    NSString *filePath = fileURL.path;
    NSOperationQueue *queue = [self queueForFilePath:filePath];
    [queue addOperationWithBlock:^
    {
        NSError *error = nil;
        NSData *data = [[NSData alloc] initWithContentsOfFile:filePath
                                                      options:NSDataReadingMappedIfSafe
                                                        error:&error];
        if (error)
        {
            NSLog(@"Error reading file path '%@'\n%@", filePath, error.localizedDescription);
        }
        callback ? callback(data, error) : nil;
    }];
}

- (void)removeFileAtURL:(NSURL *)fileURL
{
    NSString *filePath = fileURL.path;
    __weak NSThread *weakThread = NSThread.currentThread;
    __weak __typeof(self) weakSelf = self;
    NSOperationQueue *queue = [self queueForFilePath:filePath];
    [queue addOperationWithBlock:^
    {
        [NSFileManager removeItemAtURL:fileURL];
        [weakThread performBlockOnThread:^
        {
            [weakSelf.queues removeObjectForKey:filePath];
        }];
    }];
    [self.queues removeObjectForKey:filePath];
}

- (void)removeDirectoryAtURL:(NSURL *)directoryURL
{
    if ([self isSafeToRemoveAll])
    {
        [NSFileManager removeItemAtURL:directoryURL];
        [self.queues removeAllObjects];
    }
    else
    {
        NSArray *files = [NSFileManager contentsOfDirectoryAtURL:directoryURL];
        [files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
        {
            [self removeFileAtURL:[directoryURL URLByAppendingPathComponent:obj]];
        }];
    }
}

#pragma mark - private

- (NSOperationQueue *)queueForFilePath:(NSString *)filePath
{
    NSOperationQueue *queue = [self.queues objectForKey:filePath];
    if (!queue)
    {
        queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 1;
        [self.queues setObject:queue forKey:filePath];
    }
    return queue;
}

- (BOOL)isSafeToRemoveAll
{
    __block BOOL result = YES;
    if (self.queues.count > 0)
    {
        [self.queues enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
        {
            result = ((NSOperationQueue *)obj).operationCount == 0;
            *stop = !result;
        }];
    }
    return result;
}

@end
