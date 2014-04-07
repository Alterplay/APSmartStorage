//
//  APSmartStorage.h
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/15/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Deprecated.h"

typedef id (^APParsingBlock)(NSData *data, NSURL *url);

@interface APSmartStorage : NSObject

@property (nonatomic, copy) APParsingBlock parsingBlock;
@property (nonatomic, assign) NSUInteger maxObjectCount;
@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;

+ (instancetype)sharedInstance;
- (void)loadObjectWithURL:(NSURL *)url completion:(void (^)(id object, NSError *))completion;
- (void)loadObjectWithURL:(NSURL *)url storeInMemory:(BOOL)storeInMemory
                 completion:(void (^)(id object, NSError *))completion;
- (void)loadObjectWithURL:(NSURL *)url storeInMemory:(BOOL)storeInMemory
                 progress:(void (^)(NSUInteger percents))progress
               completion:(void (^)(id object, NSError *))completion;
- (void)reloadObjectWithURL:(NSURL *)url completion:(void (^)(id object, NSError *))completion;
- (void)reloadObjectWithURL:(NSURL *)url storeInMemory:(BOOL)storeInMemory
                   completion:(void (^)(id object, NSError *))completion;
- (void)reloadObjectWithURL:(NSURL *)url storeInMemory:(BOOL)storeInMemory
                   progress:(void (^)(NSUInteger percents))progress
                 completion:(void (^)(id object, NSError *))completion;
- (void)removeObjectWithURLFromMemory:(NSURL *)url;
- (void)removeObjectWithURLFromStorage:(NSURL *)url;
- (void)removeAllFromMemory;
- (void)removeAllFromStorage;

@end

@interface APSmartStorage (Deprecated)

- (void)loadObjectWithURL:(NSURL *)url callback:(void (^)(id object, NSError *))callback
AP_DEPRECATED("loadObjectWithURL:(NSURL *)url completion:");
- (void)loadObjectWithURL:(NSURL *)url storeInMemory:(BOOL)storeInMemory
                 callback:(void (^)(id object, NSError *))callback
AP_DEPRECATED("loadObjectWithURL:storeInMemory:completion:");
- (void)reloadObjectWithURL:(NSURL *)url callback:(void (^)(id object, NSError *))callback
AP_DEPRECATED("reloadObjectWithURL:completion:");
- (void)reloadObjectWithURL:(NSURL *)url storeInMemory:(BOOL)storeInMemory
                   callback:(void (^)(id object, NSError *))callback
AP_DEPRECATED("reloadObjectWithURL:storeInMemory:completion:");
- (void)removeObjectWithURL:(NSURL *)objectURL AP_DEPRECATED("removeObjectWithURLFromMemory:");
- (void)removeAllObjects AP_DEPRECATED("removeAllFromMemory");
- (void)cleanObjectWithURL:(NSURL *)url AP_DEPRECATED("removeAllFromMemory");
- (void)cleanAllObjects AP_DEPRECATED("removeAllFromStorage");

@end