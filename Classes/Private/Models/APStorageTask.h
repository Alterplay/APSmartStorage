//
//  APStorageTask.h
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/23/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^APTaskCallbackBlock)(id object, NSError *error);

@interface APStorageTask : NSObject

- (void)addCallbackBlock:(APTaskCallbackBlock)block thread:(NSThread *)thread;
- (void)performCallbackWithObject:(id)object error:(NSError *)error;

@end
