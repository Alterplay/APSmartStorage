//
//  APSmartStorage.h
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/15/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^APParsingBlock)(NSData *data, NSURL *url);

@interface APSmartStorage : NSObject

@property (nonatomic, copy) APParsingBlock parsingBlock;
@property (nonatomic, assign) NSUInteger maxObjectCount;
@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;

+ (instancetype)sharedInstance;
- (void)loadObjectWithURL:(NSURL *)url callback:(void (^)(id object, NSError *))callback;
- (void)reloadObjectWithURL:(NSURL *)url callback:(void (^)(id object, NSError *))callback;
- (void)removeObjectWithURLFromMemory:(NSURL *)url;
- (void)removeObjectWithURLFromStorage:(NSURL *)url;
- (void)removeAllFromMemory;
- (void)removeAllFromStorage;

// deprecated
- (void)removeObjectWithURL:(NSURL *)objectURL __attribute__((deprecated("Use 'removeObjectWithURLFromMemory:' instead")));
- (void)removeAllObjects __attribute__((deprecated("Use 'removeAllFromMemory' instead")));
- (void)cleanObjectWithURL:(NSURL *)url __attribute__((deprecated("Use 'removeObjectWithURLFromStorage:' instead")));
- (void)cleanAllObjects __attribute__((deprecated("Use 'removeAllFromStorage' instead")));

@end
