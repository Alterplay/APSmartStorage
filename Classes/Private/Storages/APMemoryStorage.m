//
//  APMemoryStorage.m
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/20/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "APMemoryStorage.h"
#import "APAsyncDictionary.h"
#import "APAsyncDictionary+TrimCount.h"

@interface APMemoryStorage ()
{
    APAsyncDictionary *dictionary;
}
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

- (id)objectWithURL:(NSURL *)url
{
    return [dictionary objectForKeySynchronously:url.absoluteString];
}

- (void)setObject:(id)object forURL:(NSURL *)url
{
    if (object)
    {
        // is need to check stored object count
        if (self.maxCount > 0)
        {
            [dictionary trimObjectsToCount:(self.maxCount - 1)];
        }
        [dictionary setObject:object forKey:url.absoluteString];
    }
}

- (void)removeObjectForURL:(NSURL *)url
{
    [dictionary removeObjectForKey:url.absoluteString];
}

- (void)removeAllObjects
{
    [dictionary removeAllObjects];
}

#pragma mark - properties

- (void)setMaxCount:(NSUInteger)maxCount
{
    if (maxCount != 0 && maxCount < _maxCount)
    {
        [dictionary trimObjectsToCount:maxCount];
    }
    _maxCount = maxCount;
}

@end
