//
//  APAsyncDictionary+TrimCount.h
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/20/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "APAsyncDictionary.h"

@interface APAsyncDictionary (TrimCount)

- (void)trimObjectsToCount:(NSUInteger)maxCount;

@end
