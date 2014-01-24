//
//  APNetworkStorage.m
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/17/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "APNetworkStorage.h"

@interface APNetworkStorage ()
{
    NSURLSession *session;
    NSOperationQueue *queue;
}
@end

@implementation APNetworkStorage

#pragma mark - life cycle

- (id)init
{
    NSURLSessionConfiguration *config = NSURLSessionConfiguration.defaultSessionConfiguration;
    return [self initWithURLSessionConfiguration:config];
}

- (id)initWithURLSessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    self = [super init];
    if (self)
    {
        queue = [[NSOperationQueue alloc] init];
        session = [NSURLSession sessionWithConfiguration:configuration delegate:nil
                                           delegateQueue:queue];
    }
    return self;
}

#pragma mark - public

- (void)downloadURL:(NSURL *)url callback:(void (^)(NSString *path, NSError *error))callback
{
    [[session downloadTaskWithURL:url
                completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
    {
        callback ? callback(location.path, error) : nil;
    }] resume];
}

@end
