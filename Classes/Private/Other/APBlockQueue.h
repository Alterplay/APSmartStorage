//
//  APBlockQueue.h
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/23/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APBlockQueue : NSObject

- (void)enqueueBlock:(void (^)())block;

@end
