//
//  APSmartStorage.h
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/15/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APSmartStorage : NSObject

// initialization
- (id)initWithCustomSessionConfiguration:(NSURLSessionConfiguration *)configuration;
// load object
- (void)loadObjectWithURL:(NSURL *)objectURL keepInMemory:(BOOL)keepInMemory
                 callback:(void (^)(id object, NSError *))callback;
- (void)reloadObjectWithURL:(NSURL *)objectURL keepInMemory:(BOOL)keepInMemory
                   callback:(void (^)(id object, NSError *))callback;
// remove object
- (void)removeObjectWithURL:(NSURL *)objectURL;
- (void)removeAllObjects;
// clean object (also remove files)
- (void)cleanObjectWithURL:(NSURL *)objectURL;
- (void)cleanAllObjects;

@end
