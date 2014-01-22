//
//  OHHTTPStubs+AllRequests.m
//  APSmartStorageSpec
//
//  Created by Alexey Belkevich on 1/22/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "OHHTTPStubs+AllRequests.h"

@implementation OHHTTPStubs (AllRequests)

+ (void)stubAllRequestsWithResponseData:(NSData *)data
{
    [self stubRequestsPassingTest:^BOOL(NSURLRequest *request)
    {
        return YES;
    }            withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request)
    {
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];

}

+ (void)stubAllRequestsWithNetworkDown
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request)
    {
        return YES;
    }                   withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request)
    {
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                             code:kCFURLErrorNotConnectedToInternet userInfo:nil];
        return [OHHTTPStubsResponse responseWithError:error];
    }];
}

@end
