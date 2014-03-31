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
@property (nonatomic, copy) APTaskCallbackBlock callbackBlock;
@end

@implementation APStorageTask

#pragma mark - public

- (void)addCallbackBlock:(APTaskCallbackBlock)block thread:(NSThread *)thread
{
    if (block)
    {
        APTaskCallbackBlock threadBlock = [self wrapBlock:block toThread:thread];
        // there are no callback block exists
        if (!self.callbackBlock)
        {
            self.callbackBlock = threadBlock;
        }
        // add callback block to existing ones
        else
        {
            APTaskCallbackBlock previousBlock = [self.callbackBlock copy];
            self.callbackBlock = ^(id object, NSError *error)
            {
                previousBlock(object, error);
                threadBlock(object, error);
            };
        }
    }
}

- (void)performCallbackWithObject:(id)object error:(NSError *)error
{
    self.callbackBlock ? self.callbackBlock(object, error) : nil;
}

#pragma mark - private

- (APTaskCallbackBlock)wrapBlock:(APTaskCallbackBlock)block toThread:(NSThread *)thread
{
    return ^(id object, NSError *error)
    {
        [NSThread performOnThread:thread block:^
        {
            block(object, error);
        }];
    };
}

@end
