//
//  APSmartStorageSpec.mm
//  APSmartStorageSpec
//
//  Created by Alexey Belkevich on 1/16/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "CedarAsync.h"
#import "APSmartStorage.h"
#import "APStoragePathHelper.h"
#import "OHHTTPStubs.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(APSmartStorageSpec)

describe(@"APSmartStorage", ^
{
    __block APSmartStorage *storage;
    __block NSURL *objectURL;
    __block id responseObject;
    __block id checkObject;

    beforeEach((id)^
    {
        storage = [[APSmartStorage alloc] init];
        objectURL = [NSURL URLWithString:@"http://example.com/object_data"];
        responseObject = [@"APSmartStorage string" dataUsingEncoding:NSUTF8StringEncoding];
    });

    afterEach((id)^
    {
        [storage removeAllObjects];
        [OHHTTPStubs removeAllStubs];
        checkObject = nil;
    });

    it(@"should run callback on the same thread as method call", ^
    {
        __block NSThread *callbackThread;
        NSThread *currentThread = NSThread.currentThread;
        [storage loadObjectWithURL:objectURL keepInMemory:YES callback:^(id object, NSError *error)
        {
            callbackThread = NSThread.currentThread;
        }];
        in_time(callbackThread) should equal(currentThread);
    });

    it(@"should load object with URL from network", ^
    {
        // mocking network request
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request)
        {
            return YES;
        }                   withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request)
        {
            return [OHHTTPStubsResponse responseWithData:responseObject statusCode:200 headers:nil];
        }];
        // loading object
        [storage loadObjectWithURL:objectURL keepInMemory:YES callback:^(id object, NSError *error)
        {
            checkObject = object;
        }];
        in_time(checkObject) should_not be_nil;
        in_time(checkObject) should equal(responseObject);
    });

    it(@"should load object with URL from file", ^
    {
        // mocking file
        NSURL *url = [APStoragePathHelper storageURLForNetworkURL:objectURL];
        [responseObject writeToURL:url atomically:YES];
        // loading object
        [storage loadObjectWithURL:objectURL keepInMemory:YES callback:^(id object, NSError *error)
        {
            checkObject = object;
        }];
        in_time(checkObject) should_not be_nil;
        in_time(checkObject) should equal(responseObject);
    });
});

SPEC_END
