//
//  APAsyncDictionary+TrimCount.m
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/20/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "APAsyncDictionary+TrimCount.h"

@interface APAsyncDictionary ()
- (void)runDictionaryAsynchronousWriteBlock:(void(^)(NSMutableDictionary *dictionary))block;
@end

@implementation APAsyncDictionary (TrimCount)

- (void)trimObjectsToCount:(NSUInteger)maxCount
{
    [self runDictionaryAsynchronousWriteBlock:^(NSMutableDictionary *dictionary)
    {
        while (dictionary.count > maxCount)
        {
            id <NSCopying> anyKey = dictionary.allKeys.firstObject;
            [dictionary removeObjectForKey:anyKey];
        }
    }];
}

@end
