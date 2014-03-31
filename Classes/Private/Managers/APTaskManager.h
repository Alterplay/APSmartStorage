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

- (void)addTaskWithURL:(NSURL *)url block:(APTaskCallbackBlock)block
           shouldStart:(BOOL *)shouldStart;
- (void)finishTaskWithURL:(NSURL *)url object:(id)object error:(NSError *)error;
- (void)cancelTaskWithURL:(NSURL *)url;
- (void)cancelAllTasks;

@end