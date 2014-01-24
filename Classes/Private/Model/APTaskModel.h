//
//  APTaskModel.h
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/23/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^APTaskCallbackBlock)(id object, NSError *error);

@interface APTaskModel : NSObject

@property (nonatomic, readonly) BOOL isShouldRunTask;

- (void)updateCallbackBlockWithThread:(NSThread *)thread block:(APTaskCallbackBlock)block;
- (void)performCallbackBlockWithObject:(id)object error:(NSError *)error;

@end
