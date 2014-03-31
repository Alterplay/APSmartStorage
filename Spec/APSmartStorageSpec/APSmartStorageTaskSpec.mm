//
//  APSmartStorageTaskSpec.mm
//  APSmartStorageSpec
//
//  Created by Alexey Belkevich on 1/24/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "CedarAsync.h"
#import "APSmartStorage.h"
#import "OHHTTPStubs+AllRequests.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(APSmartStorageTaskSpec)

describe(@"APSmartStorage", ^
{
    __block APSmartStorage *storage;
    __block NSURL *objectURL;
    __block id responseObject1, responseObject2;
    __block NSUInteger requestCount;

    beforeEach((id)^
    {
        storage = [[APSmartStorage alloc] init];
        objectURL = [NSURL URLWithString:@"http://example.com/object_data"];
        responseObject1 = [@"response 1" dataUsingEncoding:NSUTF8StringEncoding];
        responseObject2 = [@"response 2" dataUsingEncoding:NSUTF8StringEncoding];
        // mocking network request
        requestCount = 0;
        [OHHTTPStubs stubAllRequestsWithStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request)
        {
            NSData *data = requestCount > 0 ? responseObject2 : responseObject1;
            requestCount++;
            return [[OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil]
                                         requestTime:0.1f responseTime:0.1f];
        }];
    });

    afterEach((id)^
    {
        [storage cleanAllObjects];
        [OHHTTPStubs removeAllStubs];
    });

    it(@"should call 2 callbacks on first load", ^
    {
        // loading object and check file and memory
        __block id checkObject1 = [[NSObject alloc] init];
        __block id checkObject2 = [[NSObject alloc] init];
        [storage loadObjectWithURL:objectURL callback:^(id object, NSError *error)
        {
            checkObject1 = object;
        }];
        [storage loadObjectWithURL:objectURL callback:^(id object, NSError *error)
        {
            checkObject2 = object;
        }];
        in_time(checkObject1) should equal(responseObject1);
        in_time(checkObject2) should equal(responseObject1);
        in_time(requestCount) should equal(1);
    });
});

SPEC_END