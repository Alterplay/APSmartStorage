//
//  APFileStorage.h
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/16/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APFileStorage : NSObject

- (void)dataWithURL:(NSURL *)url callback:(void(^)(NSData *data))callback;
- (BOOL)moveDataWithURL:(NSURL *)url downloadedToPath:(NSString *)path error:(NSError **)error;
- (void)removeFileForURL:(NSURL *)url;
- (void)removeAllFiles;

@end