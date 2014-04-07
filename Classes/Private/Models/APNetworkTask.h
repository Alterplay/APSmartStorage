//
//  APNetworkTask.h
//  APSmartStorageSpec
//
//  Created by Alexey Belkevich on 4/7/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^APNetworkProgressBlock)(NSUInteger percents);
typedef void (^APNetworkCompletionBlock)(NSString *path, NSError *error);

@interface APNetworkTask : NSObject

@property (nonatomic, copy) APNetworkProgressBlock progressBlock;
@property (nonatomic, copy) APNetworkCompletionBlock completionBlock;

- (id)initWithDownloadTask:(NSURLSessionDownloadTask *)task;
- (void)start;
- (void)cancel;

@end
