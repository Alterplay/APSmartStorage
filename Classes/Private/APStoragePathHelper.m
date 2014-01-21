//
//  APStoragePathHelper.m
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/17/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "APStoragePathHelper.h"
#import "NSString+MD5.h"

@implementation APStoragePathHelper

#pragma mark - public

+ (NSURL *)storageURLForNetworkURL:(NSURL *)networkURL
{
    NSString *md5 = networkURL.absoluteString.MD5Digest;
    NSString *path = [self storageDirectoryPath];
    path = [path stringByAppendingPathComponent:md5];
    return [NSURL fileURLWithPath:path];
}

+ (NSURL *)storageDirectoryURL
{
    return [NSURL fileURLWithPath:[self storageDirectoryPath]];
}

#pragma mark - private

+ (NSString *)storageDirectoryPath
{
    NSString *path = [self documentsDirectoryPath];
    path = [path stringByAppendingPathComponent:@"APSmartStorage"];
    if (![NSFileManager.defaultManager fileExistsAtPath:path isDirectory:NULL])
    {
        NSError *error = nil;
        [NSFileManager.defaultManager createDirectoryAtPath:path withIntermediateDirectories:YES
                                                 attributes:nil error:&error];
        if (error)
        {
            NSLog(@"Error creating directory at path '%@'\n%@", path, error.localizedDescription);
        }
    }
    return path;
}

+ (NSString *)documentsDirectoryPath
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [array firstObject];
}

@end
