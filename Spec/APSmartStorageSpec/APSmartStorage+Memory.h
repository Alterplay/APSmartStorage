//
//  APSmartStorage+Memory.h
//  APSmartStorageSpec
//
//  Created by Alexey Belkevich on 4/2/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "APSmartStorage.h"

@interface APSmartStorage (Memory)

- (void)objectFromMemoryWithURL:(NSURL *)objectURL callback:(void (^)(id object))callback;

@end
