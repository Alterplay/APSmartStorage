//
//  NSFileManager+Storage.m
//  APSmartStorageSpec
//
//  Created by Alexey Belkevich on 1/17/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "NSFileManager+Storage.h"

@implementation NSFileManager (Storage)

+ (void)moveFileAtURL:(NSURL *)sourceURL toURL:(NSURL *)destinationURL
{
    NSError *error = nil;
    [NSFileManager.defaultManager moveItemAtPath:sourceURL.path toPath:destinationURL.path
                                           error:&error];
    if (error)
    {
        NSLog(@"Error moving file '%@' to '%@'\n%@", sourceURL.path, destinationURL.path,
              error.localizedDescription);
    }
}

+ (void)removeItemAtURL:(NSURL *)url
{
    NSString *path = url.path;
    NSError *error = nil;
    [NSFileManager.defaultManager removeItemAtPath:path error:&error];
    if (error)
    {
        NSLog(@"Error removing file at path '%@'\n%@", path, error.localizedDescription);
    }
}

+ (NSArray *)contentsOfDirectoryAtURL:(NSURL *)url
{
    NSError *error = nil;
    NSArray *items = [NSFileManager.defaultManager contentsOfDirectoryAtPath:url.path error:&error];
    if (error)
    {
        NSLog(@"Error loading file list at '%@'\n%@", url.path, error.localizedDescription);
        return nil;
    }
    return items;
}

@end
