//
//  APMemoryStorage.h
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/20/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APMemoryStorage : NSObject

- (id)initWithMaxObjectCount:(NSUInteger)count;
- (void)objectForLocalURL:(NSURL *)localURL callback:(void(^)(id object))callback;
- (void)setObject:(id)object forLocalURL:(NSURL *)localURL;
- (void)removeObjectForLocalURL:(NSURL *)localURL;
- (void)removeAllObjects;

@end
