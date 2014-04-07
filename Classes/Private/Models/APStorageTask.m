//
//  APStorageTask.m
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/23/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "APStorageTask.h"
#import "NSThread+Block.h"

@interface APStorageTask ()
@property (atomic, copy) APTaskCompletionBlock completionBlock;
@property (atomic, copy) APTaskProgressBlock progressBlock;
@property (atomic, assign) BOOL isShouldRun;
@end

@implementation APStorageTask

#pragma mark - life cycle

- (id)initWithTaskURL:(NSURL *)url
{
    self = [super init];
    if (self)
    {
        _url = url;
        _isShouldRun = YES;
    }
    return self;
}

#pragma mark - public

- (void)addCompletionBlock:(APTaskCompletionBlock)block thread:(NSThread *)thread
{
    if (block)
    {
        APTaskCompletionBlock threadBlock = [self wrapCompletionBlock:block toThread:thread];
        // there are no callback block exists
        if (!self.completionBlock)
        {
            self.completionBlock = threadBlock;
        }
        // add callback block to existing ones
        else
        {
            APTaskCompletionBlock previousBlock = [self.completionBlock copy];
            self.completionBlock = ^(id object, NSError *error)
            {
                previousBlock(object, error);
                threadBlock(object, error);
            };
            self.isShouldRun = NO;
        }
    }
}

- (void)performCompletionWithObject:(id)object error:(NSError *)error
{
    self.completionBlock ? self.completionBlock(object, error) : nil;
}

- (void)addProgressBlock:(APTaskProgressBlock)block thread:(NSThread *)thread
{
    if (block)
    {
        APTaskProgressBlock threadBlock = [self wrapProgressBlock:block toThread:thread];
        APTaskProgressBlock previousBlock = [self.progressBlock copy];
        self.progressBlock = !previousBlock ? threadBlock : ^(NSUInteger percents)
        {
            previousBlock(percents);
            threadBlock(percents);
        };
    }
}

- (void)performProgressWithPercents:(NSUInteger)percents
{
    self.progressBlock ? self.progressBlock(percents) : nil;
}

#pragma mark - private

- (APTaskCompletionBlock)wrapCompletionBlock:(APTaskCompletionBlock)block toThread:(NSThread *)thread
{
    return ^(id object, NSError *error)
    {
        [NSThread performOnThread:thread block:^
        {
            block(object, error);
        }];
    };
}

- (APTaskProgressBlock)wrapProgressBlock:(APTaskProgressBlock)block toThread:(NSThread *)thread
{
    return ^(NSUInteger percents)
    {
        [NSThread performOnThread:thread block:^
        {
            block(percents);
        }];
    };
}

@end
