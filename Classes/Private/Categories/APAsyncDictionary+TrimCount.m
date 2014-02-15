//
//  APAsyncDictionary+TrimCount.m
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/20/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "APAsyncDictionary+TrimCount.h"

@interface APAsyncDictionary ()
- (void)runDictionaryAsynchronousBlock:(void(^)(NSMutableDictionary *dictionary))operationBlock;
@end

@implementation APAsyncDictionary (TrimCount)

- (void)trimObjectsToCount:(NSUInteger)maxCount
{
    [self runDictionaryAsynchronousBlock:^(NSMutableDictionary *dictionary)
    {
        while (dictionary.count > maxCount)
        {
            id <NSCopying> anyKey = dictionary.allKeys.firstObject;
            [dictionary removeObjectForKey:anyKey];
        }
    }];
}

@end
