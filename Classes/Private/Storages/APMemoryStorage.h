//
//  APMemoryStorage.h
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/20/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APMemoryStorage : NSObject

@property (nonatomic, assign) NSUInteger maxCount;

- (id)initWithMaxObjectCount:(NSUInteger)count;
- (id)objectWithURL:(NSURL *)url;
- (void)setObject:(id)object forURL:(NSURL *)url;
- (void)removeObjectForURL:(NSURL *)url;
- (void)removeAllObjects;

@end
