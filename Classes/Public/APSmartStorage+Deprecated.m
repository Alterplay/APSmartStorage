//
//  APSmartStorage+Deprecated.m
//  APSmartStorage
//
//  Created by Alexey Belkevich on 4/3/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "APSmartStorage.h"

@implementation APSmartStorage (Deprecated)

#pragma mark - deprecated

- (void)loadObjectWithURL:(NSURL *)url callback:(void (^)(id object, NSError *))callback
{
    [self loadObjectWithURL:url storeInMemory:YES completion:callback];
}

- (void)loadObjectWithURL:(NSURL *)url storeInMemory:(BOOL)storeInMemory
                 callback:(void (^)(id object, NSError *))callback
{
    [self loadObjectWithURL:url storeInMemory:storeInMemory completion:callback];
}

- (void)reloadObjectWithURL:(NSURL *)url callback:(void (^)(id object, NSError *))callback
{
    [self reloadObjectWithURL:url completion:callback];
}

- (void)reloadObjectWithURL:(NSURL *)url storeInMemory:(BOOL)storeInMemory
                   callback:(void (^)(id object, NSError *))callback
{
    [self reloadObjectWithURL:url storeInMemory:storeInMemory completion:callback];
}

- (void)removeObjectWithURL:(NSURL *)url
{
    [self removeObjectWithURLFromMemory:url];
}

- (void)removeAllObjects
{
    [self removeAllFromMemory];
}

- (void)cleanObjectWithURL:(NSURL *)url
{
    [self removeObjectWithURLFromStorage:url];
}

- (void)cleanAllObjects
{
    [self removeAllFromStorage];
}

@end
