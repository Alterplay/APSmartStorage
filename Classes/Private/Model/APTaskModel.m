//
//  APTaskModel.m
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/23/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "APTaskModel.h"
#import "NSThread+Block.h"

@interface APTaskModel ()
@property (nonatomic, copy) APTaskCallbackBlock callbackBlock;
@end

@implementation APTaskModel

#pragma mark - life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        _isShouldRunTask = YES;
    }
    return self;
}

#pragma mark - public

- (void)updateCallbackBlockWithThread:(NSThread *)thread block:(APTaskCallbackBlock)block
{
    if (block)
    {
        APTaskCallbackBlock threadBlock = [self callbackThread:thread block:block];
        // no callback block exists
        if (!self.callbackBlock)
        {
            self.callbackBlock = threadBlock;
        }
        // there are
        else
        {
            APTaskCallbackBlock previousBlock = [self.callbackBlock copy];
            self.callbackBlock = ^(id object, NSError *error)
            {
                previousBlock(object, error);
                threadBlock(object, error);
            };
            _isShouldRunTask = NO;
        }
    }
}

- (void)performCallbackBlockWithObject:(id)object error:(NSError *)error
{
    self.callbackBlock ? self.callbackBlock(object, error) : nil;
}

#pragma mark - private

- (APTaskCallbackBlock)callbackThread:(NSThread *)thread block:(APTaskCallbackBlock)block
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
