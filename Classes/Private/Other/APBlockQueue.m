//
//  APBlockQueue.m
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/23/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "APBlockQueue.h"

@interface APBlockQueue ()
{
    dispatch_queue_t queue;
}
@end

@implementation APBlockQueue

#pragma mark - life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        NSString *name = [NSString stringWithFormat:@"com.alterplay.blockqueue.%ld",
                                   (unsigned long)self.hash];
        queue = dispatch_queue_create([name cStringUsingEncoding:NSASCIIStringEncoding], NULL);
    }
    return self;
}

#pragma mark - public

- (void)enqueueBlock:(void (^)())block
{
    if (block)
    {
        dispatch_async(queue, ^
        {
            block();
        });
    }
}

@end
