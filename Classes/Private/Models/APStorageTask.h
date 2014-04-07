//
//  APStorageTask.h
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/23/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^APTaskCompletionBlock)(id object, NSError *error);
typedef void (^APTaskProgressBlock)(NSUInteger percents);

@interface APStorageTask : NSObject

@property (nonatomic, readonly) NSURL *url;
@property (atomic, readonly) BOOL isShouldRun;
@property (atomic, assign) BOOL storeInMemory;

- (id)initWithTaskURL:(NSURL *)url;
- (void)addCompletionBlock:(APTaskCompletionBlock)block thread:(NSThread *)thread;
- (void)performCompletionWithObject:(id)object error:(NSError *)error;
- (void)addProgressBlock:(APTaskProgressBlock)block thread:(NSThread *)thread;
- (void)performProgressWithPercents:(NSUInteger)percents;

@end
