//
//  APTaskManager.m
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/23/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <APAsyncDictionary/APAsyncDictionary.h>
#import "APTaskManager.h"
#import "NSError+APSmartStorage.h"

@interface APTaskManager ()
{
    APAsyncDictionary *_dictionary;
}
@end

@implementation APTaskManager

#pragma mark - life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        _dictionary = [[APAsyncDictionary alloc] init];
    }
    return self;
}

#pragma mark - public

- (APStorageTask *)addTaskWithURL:(NSURL *)url storeInMemory:(BOOL)storeInMemory
                  completionBlock:(APTaskCompletionBlock)completionBlock
                    progressBlock:(APTaskProgressBlock)progressBlock
{
    APStorageTask *task;
    NSString *key = url.absoluteString;
    if (key)
    {
        task = [_dictionary objectForKeySynchronously:key];
        if (!task)
        {
            task = [[APStorageTask alloc] initWithTaskURL:url];
            [_dictionary setObject:task forKey:key];
        }
        if (storeInMemory)
        {
            task.storeInMemory = storeInMemory;
        }
        NSThread *thread = NSThread.currentThread;
        [task addCompletionBlock:completionBlock thread:thread];
        [task addProgressBlock:progressBlock thread:thread];
    }
    return task;
}

- (void)progressTaskWithURL:(NSURL *)url percents:(NSUInteger)percents
{
    APStorageTask *task = [_dictionary objectForKeySynchronously:url.absoluteString];
    [task performProgressWithPercents:percents];
}

- (void)finishTaskWithURL:(NSURL *)url object:(id)object error:(NSError *)error
{
    NSString *key = url.absoluteString;
    APStorageTask *task = [_dictionary objectForKeySynchronously:key];
    [_dictionary removeObjectForKey:key];
    if (object && !error)
    {
        [task performProgressWithPercents:100];
    }
    [task performCompletionWithObject:object error:error];
}

- (void)cancelTaskWithURL:(NSURL *)url
{
    [self finishTaskWithURL:url object:nil error:[NSError errorTaskWithURLCancelled:url]];
}

- (void)cancelAllTasks
{
    [_dictionary allObjectsCallback:^(NSArray *objects)
    {
        NSError *error = [NSError errorTaskWithURLCancelled:nil ];
        for (APStorageTask *task in objects)
        {
            [task performCompletionWithObject:nil error:error];
        }
    }];
    [_dictionary removeAllObjects];
}

@end
