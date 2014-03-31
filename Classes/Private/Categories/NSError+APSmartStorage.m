//
//  NSError+APSmartStorage.m
//  APSmartStorageSpec
//
//  Created by Alexey Belkevich on 3/31/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "NSError+APSmartStorage.h"

@implementation NSError (APSmartStorage)

+ (NSError *)errorTaskWithURLCancelled:(NSURL *)url
{
    NSString *string = [NSString stringWithFormat:@"Task has been cancelled:\n%@",
                                 url.absoluteString];
    NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey : string};
    return [NSError errorWithDomain:@"com.alterplay.APSmartStorage" code:701 userInfo:userInfo];
}

@end
