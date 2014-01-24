//
//  APTaskManager.h
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/23/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APTaskModel.h"

@interface APTaskManager : NSObject

- (void)taskWithURL:(NSURL *)url block:(APTaskCallbackBlock)block
                              callback:(void (^)(BOOL isShouldRunTask))callback;
- (void)finishTaskWithURL:(NSURL *)url object:(id)object error:(NSError *)error;

@end