//
//  APNetworkTask.m
//  APSmartStorageSpec
//
//  Created by Alexey Belkevich on 4/7/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "APNetworkTask.h"

@interface APNetworkTask ()
{
    NSURLSessionDownloadTask *_task;
}
@end

@implementation APNetworkTask

#pragma mark - life cycle

- (id)initWithDownloadTask:(NSURLSessionDownloadTask *)task
{
    self = [super init];
    if (self)
    {
        _task = task;
    }
    return self;
}

#pragma mark - public

- (void)start
{
    [_task resume];
}

- (void)cancel
{
    [_task cancel];
}

@end
