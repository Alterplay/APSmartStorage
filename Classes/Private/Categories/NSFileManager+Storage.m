//
//  NSFileManager+Storage.m
//  APSmartStorageSpec
//
//  Created by Alexey Belkevich on 1/17/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "NSFileManager+Storage.h"

@implementation NSFileManager (Storage)

+ (BOOL)fileExistsAtPath:(NSString *)path
{
    return [NSFileManager.defaultManager fileExistsAtPath:path];
}

+ (void)moveFileAtPath:(NSString *)sourcePath toPath:(NSString *)destinationPath
{
    NSError *error = nil;
    NSFileManager *manager = NSFileManager.defaultManager;
    if ([manager fileExistsAtPath:destinationPath])
    {
        [self removeItemAtPath:destinationPath];
    }
    [manager moveItemAtPath:sourcePath toPath:destinationPath error:&error];
    if (error)
    {
        NSLog(@"Error moving file '%@' to '%@'\n%@", sourcePath, destinationPath,
              error.localizedDescription);
    }
}

+ (void)removeItemAtPath:(NSString *)path
{
    NSError *error = nil;
    [NSFileManager.defaultManager removeItemAtPath:path error:&error];
    if (error)
    {
        NSLog(@"Error removing file at path '%@'\n%@", path, error.localizedDescription);
    }
}

+ (void)createDirectoryAtPath:(NSString *)path
{
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
}

+ (NSString *)documentsDirectoryPath
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [array firstObject];
}


@end
