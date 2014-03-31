//
//  APSmartStorageCancelSpec.mm
//  APSmartStorageSpec
//
//  Created by Alexey Belkevich on 3/28/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "CedarAsync.h"
#import "APSmartStorage.h"
#import "OHHTTPStubs+AllRequests.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(APSmartStorageCancelSpec)

describe(@"APSmartStorage", ^
{
    __block APSmartStorage *storage;
    __block NSURL *objectURL1, *objectURL2;
    __block id responseObject1, responseObject2;

    beforeEach((id)^
    {
        storage = [[APSmartStorage alloc] init];
        objectURL1 = [NSURL URLWithString:@"http://example.com/object_data1"];
        objectURL2 = [NSURL URLWithString:@"http://example.com/object_data2"];
        responseObject1 = [@"response 1" dataUsingEncoding:NSUTF8StringEncoding];
        responseObject2 = [@"response 2" dataUsingEncoding:NSUTF8StringEncoding];
        // mocking network request
        [OHHTTPStubs stubAllRequestsWithStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request)
        {
            NSData *data = ([request.URL isEqual:objectURL1]) ? responseObject1 : responseObject2;
            return [[OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil]
                                         requestTime:0.1f responseTime:0.1f];
        }];
    });

    afterEach((id)^
    {
        [storage cleanAllObjects];
        [OHHTTPStubs removeAllStubs];
    });

    it(@"should receive error if task has been removed", ^
    {
        __block id checkObject1 = [[NSObject alloc] init];
        __block NSError *receivedError = nil;
        [storage loadObjectWithURL:objectURL1 callback:^(id object, NSError *error)
        {
            checkObject1 = object;
            receivedError = error;
        }];
        [storage cleanObjectWithURL:objectURL1];
        in_time(checkObject1) should be_nil;
        in_time(receivedError) should_not be_nil;
    });

    it(@"should receive error in all callbacks if task has been removed", ^
    {
        __block id checkObject1 = [[NSObject alloc] init];
        __block id checkObject2 = [[NSObject alloc] init];
        __block NSError *receivedError1 = nil;
        __block NSError *receivedError2 = nil;
        [storage loadObjectWithURL:objectURL1 callback:^(id object, NSError *error)
        {
            checkObject1 = object;
            receivedError1 = error;
        }];
        [storage loadObjectWithURL:objectURL1 callback:^(id object, NSError *error)
        {
            checkObject2 = object;
            receivedError2 = error;
        }];
        [storage cleanObjectWithURL:objectURL1];
        in_time(checkObject1) should be_nil;
        in_time(receivedError1) should_not be_nil;
        in_time(checkObject2) should be_nil;
        in_time(receivedError2) should_not be_nil;
    });

    it(@"should receive error in all callbacks if all tasks has been removed", ^
    {
        __block id checkObject1 = [[NSObject alloc] init];
        __block id checkObject2 = [[NSObject alloc] init];
        __block NSError *receivedError1 = nil;
        __block NSError *receivedError2 = nil;
        [storage loadObjectWithURL:objectURL1 callback:^(id object, NSError *error)
        {
            checkObject1 = object;
            receivedError1 = error;
        }];
        [storage loadObjectWithURL:objectURL2 callback:^(id object, NSError *error)
        {
            checkObject2 = object;
            receivedError2 = error;
        }];
        [storage cleanAllObjects];
        in_time(checkObject1) should be_nil;
        in_time(receivedError1) should_not be_nil;
        in_time(checkObject2) should be_nil;
        in_time(receivedError2) should_not be_nil;
    });
});

SPEC_END