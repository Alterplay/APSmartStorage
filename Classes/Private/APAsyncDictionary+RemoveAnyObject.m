//
//  APAsyncDictionary+RemoveAnyObject.m
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/20/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "APAsyncDictionary+RemoveAnyObject.h"

@interface APAsyncDictionary ()
- (void)runDictionaryOperationBlock:(void(^)(NSMutableDictionary *dictionary))operationBlock;
@end

@implementation APAsyncDictionary (RemoveAnyObject)

- (void)removeAnyObjectIfCountGreaterThen:(NSUInteger)maxCount
{
    [self runDictionaryOperationBlock:^(NSMutableDictionary *dictionary)
    {
        if (dictionary.count >= maxCount)
        {
            id <NSCopying> anyKey = dictionary.allKeys.firstObject;
            [dictionary removeObjectForKey:anyKey];
        }
    }];
}

@end
