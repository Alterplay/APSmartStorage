//
//  APFileStorage.m
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/16/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <MD5Digest/NSString+MD5.h>
#import "APFileStorage.h"
#import "NSThread+Block.h"
#import "NSFileManager+Storage.h"

@interface APFileStorage ()
@property (readonly) NSString *storageDirectory;
@end

@implementation APFileStorage

#pragma mark - life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        _storageDirectory = [NSFileManager documentsDirectoryPath];
        _storageDirectory = [_storageDirectory stringByAppendingPathComponent:@"APSmartStorage"];
        [NSFileManager createDirectoryAtPath:self.storageDirectory];
    }
    return self;
}

#pragma mark - public

- (void)dataWithURL:(NSURL *)url callback:(void (^)(NSData *data))callback
{
    __weak NSThread *thread = NSThread.currentThread;
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        NSData *data = nil;
        NSString *path = [weakSelf filePathForURL:url];
        if ([NSFileManager fileExistsAtPath:path])
        {
            NSError *error = nil;
            data = [[NSData alloc] initWithContentsOfFile:path options:NSDataReadingMappedIfSafe
                                                    error:&error];
            if (error)
            {
                NSLog(@"Error reading file path '%@'\n%@", path, error.localizedDescription);
                data = nil;
            }
        }
        [NSThread performOnThread:thread block:^
        {
            callback(data);
        }];
    });
}

- (void)moveDataWithURL:(NSURL *)url downloadedToPath:(NSString *)path
{
    NSString *newPath = [self filePathForURL:url];
    [NSFileManager moveFileAtPath:path toPath:newPath];
}

- (void)removeFileForURL:(NSURL *)url
{
    NSString *path = [self filePathForURL:url];
    [NSFileManager removeItemAtPath:path];
}

- (void)removeAllFiles
{
    [NSFileManager removeItemAtPath:self.storageDirectory];
    [NSFileManager createDirectoryAtPath:self.storageDirectory];
}

#pragma mark - private

- (NSString *)filePathForURL:(NSURL *)url
{
    NSString *md5 = url.absoluteString.MD5Digest;
    return  [self.storageDirectory stringByAppendingPathComponent:md5];
}

@end
