//
//  NSFileManager+Storage.h
//  APSmartStorageSpec
//
//  Created by Alexey Belkevich on 1/17/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Storage)

+ (void)moveFileAtURL:(NSURL *)sourceURL toURL:(NSURL *)destinationURL;
+ (void)removeItemAtURL:(NSURL *)url;
+ (void)removeItemAtPath:(NSString *)path;
+ (NSArray *)contentsOfDirectoryAtURL:(NSURL *)url;

@end