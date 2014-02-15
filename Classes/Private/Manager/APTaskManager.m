//
//  APTaskManager.m
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/23/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <APAsyncDictionary/APAsyncDictionary.h>
#import "APTaskManager.h"

@interface APTaskManager ()
{
    APAsyncDictionary *tasksDictionary;
}
@end

@implementation APTaskManager

#pragma mark - life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        tasksDictionary = [[APAsyncDictionary alloc] init];
    }
    return self;
}

#pragma mark - public

- (void)taskWithURL:(NSURL *)url block:(APTaskCallbackBlock)block
                              callback:(void (^)(BOOL isShouldRunTask))callback
{
    NSString *key = url.absoluteString;
    if (key)
    {
        BOOL isShouldRunTask = NO;
        APTaskModel *task = [tasksDictionary objectForKeySynchronously:key];
        if (!task)
        {
            task = [[APTaskModel alloc] init];
            [tasksDictionary setObject:task forKey:key];
            isShouldRunTask = YES;
        }
        [task updateCallbackBlockWithThread:NSThread.currentThread block:block];
        callback(isShouldRunTask);
    }
}

- (void)finishTaskWithURL:(NSURL *)url object:(id)object error:(NSError *)error
{
    NSString *key = url.absoluteString;
    APTaskModel *task = [tasksDictionary objectForKeySynchronously:key];
    [tasksDictionary removeObjectForKey:key];
    [task performCallbackBlockWithObject:object error:error];
}

@end
