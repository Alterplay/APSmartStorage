//
//  APSmartStorageFileSpec.mm
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

SPEC_BEGIN(APSmartStorageFileSpec)

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
        // mocking network request
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request)
        {
            return YES;
        }                   withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request)
        {
            return [OHHTTPStubsResponse responseWithData:responseObject statusCode:200 headers:nil];
        }];
    });

    afterEach((id)^
    {
        [storage cleanAllObjects];
        [OHHTTPStubs removeAllStubs];
    });

    it(@"should load object from network, store it to file and keep it in memory", ^
    {
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

    it(@"should rewrite file on reload", ^
    {
        // mocking file
        NSURL *url = [APStoragePathHelper storageURLForNetworkURL:objectURL];
        [responseObject writeToURL:url atomically:YES];
        // mocking network request
        NSData *anotherData = [@"another response" dataUsingEncoding:NSUTF8StringEncoding];
        [OHHTTPStubs removeAllStubs];
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request)
        {
            return YES;
        }                   withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request)
        {
            return [OHHTTPStubsResponse responseWithData:anotherData statusCode:200 headers:nil];
        }];
        // loading object
        __block id checkData;
        [storage reloadObjectWithURL:objectURL keepInMemory:YES callback:^(id object, NSError *error)
        {
            checkData = [NSData dataWithContentsOfURL:url];
        }];
        in_time(checkData) should_not be_nil;
        in_time(checkData) should equal(anotherData);
    });

});

SPEC_END