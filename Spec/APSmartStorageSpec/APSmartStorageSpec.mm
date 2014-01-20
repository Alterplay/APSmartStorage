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
- (void)didReceiveMemoryWarning:(NSNotification *)notification;
@end

SPEC_BEGIN(APSmartStorageSpec)

describe(@"APSmartStorage", ^
{
    __block APSmartStorage *storage;
    __block NSURL *objectURL;
    __block id responseObject;

    beforeEach((id)^
    {
        NSURLSessionConfiguration *config = NSURLSessionConfiguration.defaultSessionConfiguration;
        storage = [[APSmartStorage alloc] initWithCustomSessionConfiguration:config
                                                              maxObjectCount:1];
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
            // check existence
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

    it(@"should remove any object from memory storage if max count reached", ^
    {
        // mocking network request
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request)
        {
            return YES;
        }                   withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request)
        {
            NSData *anotherData = [@"another response" dataUsingEncoding:NSUTF8StringEncoding];
            NSData *data = [request.URL.absoluteString isEqualToString:objectURL.absoluteString] ?
                           responseObject : anotherData;
            return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
        }];
        // parsing block
        storage.parsingBlock = ^(NSData *data, NSURL *url)
        {
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        };
        // loading object
        NSURL *anotherURL = [NSURL URLWithString:@"http://example.com/another_object"];
        NSURL *objectLocalURL = [APStoragePathHelper storageURLForNetworkURL:objectURL];
        NSURL *anotherLocalURL = [APStoragePathHelper storageURLForNetworkURL:anotherURL];
        __block id checkObject = [[NSObject alloc] init];
        __block id anotherObject = nil;
        [storage loadObjectWithURL:objectURL keepInMemory:YES callback:nil];
        [storage loadObjectWithURL:anotherURL keepInMemory:YES callback:^(id object, NSError *error)
        {
            [storage.memoryStorage objectForLocalURL:objectLocalURL callback:^(id object)
            {
                checkObject = object;
            }];
            [storage.memoryStorage objectForLocalURL:anotherLocalURL callback:^(id object)
            {
                anotherObject = object;
            }];
        }];
        in_time(checkObject) should be_nil;
        in_time(anotherObject) should_not be_nil;
        in_time(anotherObject) should equal(@"another response");
    });

    it(@"should remove memory objects on memory warning", ^
    {
        // mocking network request
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request)
        {
            return YES;
        }                   withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request)
        {
            NSData *anotherData = [@"another response" dataUsingEncoding:NSUTF8StringEncoding];
            NSData *data = [request.URL.absoluteString isEqualToString:objectURL.absoluteString] ?
                           responseObject : anotherData;
            return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
        }];
        // loading object
        NSURL *anotherURL = [NSURL URLWithString:@"http://example.com/another_object"];
        NSURL *objectLocalURL = [APStoragePathHelper storageURLForNetworkURL:objectURL];
        NSURL *anotherLocalURL = [APStoragePathHelper storageURLForNetworkURL:anotherURL];
        __block id checkObject = [[NSObject alloc] init];
        __block id anotherObject = [[NSObject alloc] init];
        [storage loadObjectWithURL:objectURL keepInMemory:YES callback:nil];
        [storage loadObjectWithURL:anotherURL keepInMemory:YES callback:^(id object, NSError *error)
        {
            [storage didReceiveMemoryWarning:nil];
            [storage.memoryStorage objectForLocalURL:objectLocalURL callback:^(id object)
            {
                checkObject = object;
            }];
            [storage.memoryStorage objectForLocalURL:anotherLocalURL callback:^(id object)
            {
                anotherObject = object;
            }];
        }];
        in_time(checkObject) should be_nil;
        in_time(anotherObject) should be_nil;
    });

    it(@"should rewrite file on reload", ^
    {
        // mocking file
        NSURL *url = [APStoragePathHelper storageURLForNetworkURL:objectURL];
        [responseObject writeToURL:url atomically:YES];
        // mocking network request
        NSData *anotherData = [@"another response" dataUsingEncoding:NSUTF8StringEncoding];
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request)
        {
            return YES;
        }                   withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request)
        {
            return [OHHTTPStubsResponse responseWithData:anotherData statusCode:200 headers:nil];
        }];
        // loading object
        __block id checkData;
        [storage reloadObjectWithURL:objectURL keepInMemory:YES
                            callback:^(id object, NSError *error)
        {
            checkData = [NSData dataWithContentsOfURL:url];
        }];
        in_time(checkData) should_not be_nil;
        in_time(checkData) should equal(anotherData);
    });

});

SPEC_END
