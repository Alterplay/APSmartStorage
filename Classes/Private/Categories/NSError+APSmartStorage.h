//
//  NSError+APSmartStorage.h
//  APSmartStorageSpec
//
//  Created by Alexey Belkevich on 3/31/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (APSmartStorage)

+ (NSError *)errorTaskWithURLCancelled:(NSURL *)url;

@end
