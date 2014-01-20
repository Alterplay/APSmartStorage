//
//  APMemoryStorage.m
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/20/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "APMemoryStorage.h"
#import "APAsyncDictionary.h"

@interface APMemoryStorage ()
{
    APAsyncDictionary *dictionary;
}
@property (assign, readonly) NSUInteger maxCount;
@end

@implementation APMemoryStorage

#pragma mark - life cycle

- (id)initWithMaxObjectCount:(NSUInteger)count
{
    self = [super init];
    if (self)
    {
        dictionary = [[APAsyncDictionary alloc] init];
        _maxCount = count;
    }
    return self;
}

#pragma mark - public

- (void)objectForLocalURL:(NSURL *)localURL callback:(void (^)(id object))callback
{
    [dictionary objectForKey:localURL.path callback:^(id <NSCopying> key, id object)
    {
        callback ? callback(object) : nil;
    }];
}

- (void)setObject:(id)object forLocalURL:(NSURL *)localURL
{
#warning add max count check
    [dictionary setObject:object forKey:localURL.path];
}

- (void)removeObjectForLocalURL:(NSURL *)localURL
{
    [dictionary removeObjectForKey:localURL.path];
}

- (void)removeAllObjects
{
    [dictionary removeAllObjects];
}

@end
