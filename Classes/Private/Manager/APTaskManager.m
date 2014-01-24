//
//  APTaskManager.m
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/23/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "APTaskManager.h"
#import "APBlockQueue.h"
#import "NSThread+Block.h"

@interface APTaskManager ()
{
    APBlockQueue *queue;
    NSMutableDictionary *tasksDictionary;
}
@end

@implementation APTaskManager

#pragma mark - life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        tasksDictionary = [[NSMutableDictionary alloc] init];
        queue = [[APBlockQueue alloc] init];
    }
    return self;
}

#pragma mark - public

- (void)taskWithURL:(NSURL *)url block:(APTaskCallbackBlock)block
           callback:(void (^)(APTaskModel *task))callback
{
    NSString *key = url.absoluteString;
    if (key)
    {
        __weak NSMutableDictionary *weakDictionary = tasksDictionary;
        __weak NSThread *weakThread = NSThread.currentThread;
        [queue enqueueBlock:^
        {
            APTaskModel *task = [weakDictionary objectForKey:key];
            if (!task)
            {
                task = [[APTaskModel alloc] init];
                [weakDictionary setObject:task forKey:key];
            }
            [task updateCallbackBlockWithThread:weakThread block:block];
            [NSThread performOnThread:weakThread block:^
            {
                callback(task);
            }];
        }];
    }
}

- (void)finishTaskWithURL:(NSURL *)url object:(id)object error:(NSError *)error
{
    NSString *key = url.absoluteString;
    __weak NSMutableDictionary *weakDictionary = tasksDictionary;
    [queue enqueueBlock:^
    {
        APTaskModel *task = [weakDictionary objectForKey:key];
        [weakDictionary removeObjectForKey:key];
        [task performCallbackBlockWithObject:object error:error];
    }];
}

@end
