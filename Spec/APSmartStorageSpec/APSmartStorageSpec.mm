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
#import "APMemoryStorage.h"
#import "OHHTTPStubs.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface APSmartStorage (Private)
@property (nonatomic, readonly) APMemoryStorage *memoryStorage;
@end

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
        [storage cleanAllObjects];
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

    it(@"should load object from memory storage", ^
    {
        // mock memory
        NSURL *url = [APStoragePathHelper storageURLForNetworkURL:objectURL];
        [storage.memoryStorage setObject:responseObject forLocalURL:url];
        // loading object
        [storage loadObjectWithURL:objectURL keepInMemory:YES callback:^(id object, NSError *error)
        {
            checkObject = object;
        }];
        in_time(checkObject) should_not be_nil;
        in_time(checkObject) should equal(responseObject);
    });

    it(@"should load object from network, store it to file and keep it in memory", ^
    {
        // mocking network request
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request)
        {
            return YES;
        }                   withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request)
        {
            return [OHHTTPStubsResponse responseWithData:responseObject statusCode:200 headers:nil];
        }];
        // loading object and check file and memory
        __block BOOL isFileExists, isObjectInMemory;
        [storage loadObjectWithURL:objectURL keepInMemory:YES callback:^(id object, NSError *error)
        {
            NSURL *url = [APStoragePathHelper storageURLForNetworkURL:objectURL];
            isFileExists = [NSFileManager.defaultManager fileExistsAtPath:url.path];
            [storage.memoryStorage objectForLocalURL:url callback:^(id object)
            {
                isObjectInMemory = (object != nil);
            }];
        }];
        in_time(isFileExists) should equal(YES);
        in_time(isObjectInMemory) should equal(YES);
    });

    it(@"should load object from network, store it to file and don't keep it in memory", ^
    {
        // mocking network request
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request)
        {
            return YES;
        }                   withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request)
        {
            return [OHHTTPStubsResponse responseWithData:responseObject statusCode:200 headers:nil];
        }];
        // loading object and check file and memory
        __block BOOL isFileExists = NO, isObjectInMemory = YES;
        [storage loadObjectWithURL:objectURL keepInMemory:NO callback:^(id object, NSError *error)
        {
            NSURL *url = [APStoragePathHelper storageURLForNetworkURL:objectURL];
            isFileExists = [NSFileManager.defaultManager fileExistsAtPath:url.path];
            [storage.memoryStorage objectForLocalURL:url callback:^(id object)
            {
                isObjectInMemory = (object != nil);
            }];
        }];
        in_time(isFileExists) should equal(YES);
        in_time(isObjectInMemory) should equal(NO);
    });

    it(@"should remove object from memory, but keep it at file", ^
    {
        // mocking network request
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request)
        {
            return YES;
        }                   withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request)
        {
            return [OHHTTPStubsResponse responseWithData:responseObject statusCode:200 headers:nil];
        }];
        // loading object and check file and memory
        __block BOOL isFileExists = NO, isObjectInMemory = YES;
        [storage loadObjectWithURL:objectURL keepInMemory:YES callback:^(id object, NSError *error)
        {
            // remove object
            [storage removeObjectWithURL:objectURL];
            // check existance
            NSURL *url = [APStoragePathHelper storageURLForNetworkURL:objectURL];
            isFileExists = [NSFileManager.defaultManager fileExistsAtPath:url.path];
            [storage.memoryStorage objectForLocalURL:url callback:^(id objectAfterRemove)
            {
                isObjectInMemory = (objectAfterRemove != nil);
            }];
        }];
        in_time(isFileExists) should equal(YES);
        in_time(isObjectInMemory) should equal(NO);
    });

    it(@"should remove object from memory and remove file", ^
    {
        // mocking network request
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request)
        {
            return YES;
        }                   withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request)
        {
            return [OHHTTPStubsResponse responseWithData:responseObject statusCode:200 headers:nil];
        }];
        // loading object and check file and memory
        __block BOOL isFileExists = YES, isObjectInMemory = YES;
        [storage loadObjectWithURL:objectURL keepInMemory:YES callback:^(id object, NSError *error)
        {
            // remove object
            [storage cleanObjectWithURL:objectURL];
            // check existance
            NSURL *url = [APStoragePathHelper storageURLForNetworkURL:objectURL];
            isFileExists = [NSFileManager.defaultManager fileExistsAtPath:url.path];
            [storage.memoryStorage objectForLocalURL:url callback:^(id objectAfterRemove)
            {
                isObjectInMemory = (objectAfterRemove != nil);
            }];
        }];
        in_time(isFileExists) should equal(NO);
        in_time(isObjectInMemory) should equal(NO);
    });
});

SPEC_END
