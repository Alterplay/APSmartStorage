//
//  APNetworkStorage.h
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/17/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APNetworkStorage : NSObject

- (id)initWithURLSessionConfiguration:(NSURLSessionConfiguration *)configuration;
- (void)downloadURL:(NSURL *)url progress:(void (^)(NSUInteger percents))progress
         completion:(void (^)(NSString *path, NSError *error))completion;
- (void)cancelDownloadURL:(NSURL *)url;
- (void)cancelAllDownloads;

@end
