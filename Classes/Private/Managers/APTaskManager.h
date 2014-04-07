//
//  APTaskManager.h
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/23/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APStorageTask.h"

@interface APTaskManager : NSObject

- (APStorageTask *)addTaskWithURL:(NSURL *)url storeInMemory:(BOOL)storeInMemory
                  completionBlock:(APTaskCompletionBlock)completionBlock
                    progressBlock:(APTaskProgressBlock)progressBlock;
- (void)progressTaskWithURL:(NSURL *)url percents:(NSUInteger)percents;
- (void)finishTaskWithURL:(NSURL *)url object:(id)object error:(NSError *)error;
- (void)cancelTaskWithURL:(NSURL *)url;
- (void)cancelAllTasks;

@end