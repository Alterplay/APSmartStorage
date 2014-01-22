//
//  APSmartStorageBaseSpec.mm
//  APSmartStorageSpec
//
//  Created by Alexey Belkevich on 1/22/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "CedarAsync.h"
#import "APSmartStorage.h"
#import "APStoragePathHelper.h"
#import "APMemoryStorage.h"
#import "OHHTTPStubs.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface APSmartStorage (Private)
@property (nonatomic, readonly) APMemoryStorage *memoryStorage;
@end

SPEC_BEGIN(APSmartStorageBaseSpec)

describe(@"APSmartStorage", ^
{
    __block APSmartStorage *storage;
    __block NSURL *objectURL;
    __block id responseObject;

    beforeEach((id)^
    {
        storage = [[APSmartStorage alloc] init];
        objectURL = [NSURL URLWithString:@"http://example.com/object_data"];
        responseObject = [@"APSmartStorage string" dataUsingEncoding:NSUTF8StringEncoding];
    });

    afterEach((id)^
    {
        [storage cleanAllObjects];
        storage.parsingBlock = nil;
        [OHHTTPStubs removeAllStubs];
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
        __block id checkObject = nil;
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
        __block id checkObject = nil;
        [storage loadObjectWithURL:objectURL keepInMemory:YES callback:^(id object, NSError *error)
        {
            checkObject = object;
        }];
        in_time(checkObject) should_not be_nil;
        in_time(checkObject) should equal(responseObject);
    });

    it(@"should load object from memory storage", ^
    {
        // mock memory
        NSURL *url = [APStoragePathHelper storageURLForNetworkURL:objectURL];
        [storage.memoryStorage setObject:responseObject forLocalURL:url];
        // loading object
        __block id checkObject = nil;
        [storage loadObjectWithURL:objectURL keepInMemory:YES callback:^(id object, NSError *error)
        {
            checkObject = object;
        }];
        in_time(checkObject) should_not be_nil;
        in_time(checkObject) should equal(responseObject);
    });

    it(@"should parse loaded object with block", ^
    {
        // mocking network request
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request)
        {
            return YES;
        }                   withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request)
        {
            return [OHHTTPStubsResponse responseWithData:responseObject statusCode:200 headers:nil];
        }];
        // parsing block
        storage.parsingBlock = ^(NSData *data, NSURL *url)
        {
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        };
        // loading object
        __block id checkObject = nil;
        [storage loadObjectWithURL:objectURL keepInMemory:YES callback:^(id object, NSError *error)
        {
            checkObject = object;
        }];

        in_time(checkObject) should_not be_nil;
        in_time(checkObject) should equal(@"APSmartStorage string");
    });
});

SPEC_END