//
//  APNetworkLoader.h
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/17/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APNetworkLoader : NSObject

// initialization
- (id)initWithURLSessionConfiguration:(NSURLSessionConfiguration *)configuration;
// actions
- (void)loadObjectWithURL:(NSURL *)objectURL toFileURL:(NSURL *)fileURL
                 callback:(void (^)(NSData *data, NSError *error))callback;

@end
