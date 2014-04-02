//
//  APSmartStorage+Memory.m
//  APSmartStorageSpec
//
//  Created by Alexey Belkevich on 4/2/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "APSmartStorage+Memory.h"
#import "APStorageTask.h"

@interface APSmartStorage (Private)
- (void)memoryObjectForTask:(APStorageTask *)task callback:(void (^)(id object))callback;
@end

@implementation APSmartStorage (Memory)

- (void)objectFromMemoryWithURL:(NSURL *)objectURL callback:(void (^)(id object))callback
{
    APStorageTask *task = [[APStorageTask alloc] initWithTaskURL:objectURL];
    [self memoryObjectForTask:task callback:callback];
}

@end
