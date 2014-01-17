//
//  APFileManager.h
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/16/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APFileManager : NSObject

- (BOOL)isFileExistsForURL:(NSURL *)fileURL;
- (void)loadFileAtURL:(NSURL *)fileURL callback:(void(^)(NSData *data, NSError *error))callback;
- (void)removeFileAtURL:(NSURL *)fileURL;
- (void)removeDirectoryAtURL:(NSURL *)directoryURL;

@end