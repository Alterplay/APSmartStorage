//
//  APMemoryStorage.m
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/20/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "APMemoryStorage.h"
#import "APAsyncDictionary.h"
#import "APAsyncDictionary+RemoveAnyObject.h"

@interface APMemoryStorage ()
@property (nonatomic, readonly) APAsyncDictionary *dictionary;
@property (nonatomic, readonly) NSUInteger maxCount;
@end

@implementation APMemoryStorage

#pragma mark - life cycle

- (id)initWithMaxObjectCount:(NSUInteger)count
{
    self = [super init];
    if (self)
    {
        _dictionary = [[APAsyncDictionary alloc] init];
        _maxCount = count;
    }
    return self;
}

#pragma mark - public

- (void)objectForLocalURL:(NSURL *)localURL callback:(void (^)(id object))callback
{
    [self.dictionary objectForKey:localURL.path callback:^(id <NSCopying> key, id object)
    {
        callback ? callback(object) : nil;
    }];
}

- (void)setObject:(id)object forLocalURL:(NSURL *)localURL
{
    // is need to check stored object count
    if (self.maxCount > 0)
    {
        [self.dictionary removeAnyObjectIfCountGreaterThen:self.maxCount];
    }
    [self.dictionary setObject:object forKey:localURL.path];
}

- (void)removeObjectForLocalURL:(NSURL *)localURL
{
    [self.dictionary removeObjectForKey:localURL.path];
}

- (void)removeAllObjects
{
    [self.dictionary removeAllObjects];
}

@end
