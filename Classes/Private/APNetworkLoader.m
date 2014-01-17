//
//  APNetworkLoader.m
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/17/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "APNetworkLoader.h"
#import "NSFileManager+Storage.h"

@interface APNetworkLoader ()
{
    NSURLSession *session;
    NSOperationQueue *queue;
}
@end

@implementation APNetworkLoader

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

- (void)loadObjectWithURL:(NSURL *)objectURL toFileURL:(NSURL *)fileURL
                 callback:(void (^)(NSData *data, NSError *error))callback
{
    [[session downloadTaskWithURL:objectURL
                completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
    {
        NSData *data;
        if (!error)
        {
            data = [NSData dataWithContentsOfURL:location];
            [NSFileManager moveFileAtURL:location toURL:fileURL];
        }
        callback ? callback(data, error) : nil;
    }] resume];
}

@end
