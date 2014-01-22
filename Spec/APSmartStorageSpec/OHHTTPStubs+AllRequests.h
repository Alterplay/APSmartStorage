//
//  OHHTTPStubs+AllRequests.h
//  APSmartStorageSpec
//
//  Created by Alexey Belkevich on 1/22/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "OHHTTPStubs.h"

@interface OHHTTPStubs (AllRequests)

+ (void)stubAllRequestsWithResponseData:(NSData *)data;
+ (void)stubAllRequestsWithStubResponse:(OHHTTPStubsResponseBlock)responseBlock;
+ (void)stubAllRequestsWithNetworkDown;

@end
