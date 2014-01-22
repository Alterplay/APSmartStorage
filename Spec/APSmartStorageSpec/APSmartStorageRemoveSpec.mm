//
//  APSmartStorageRemoveSpec.mm
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
- (void)didReceiveMemoryWarning:(NSNotification *)notification;
@end

SPEC_BEGIN(APSmartStorageRemoveSpec)

describe(@"APSmartStorage", ^
{
    __block APSmartStorage *storage;
    __block NSURL *objectURL;
    __block id responseObject, anotherResponse;

    beforeEach((id)^
    {
        storage = [[APSmartStorage alloc] initWithCustomSessionConfiguration:nil
                                                              maxObjectCount:1];
        objectURL = [NSURL URLWithString:@"http://example.com/object_data"];
        responseObject = [@"APSmartStorage string" dataUsingEncoding:NSUTF8StringEncoding];
        anotherResponse = [@"another response" dataUsingEncoding:NSUTF8StringEncoding];
        // mocking network request
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request)
        {
            return YES;
        }                   withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request)
        {
            NSData *data = [request.URL.absoluteString isEqualToString:objectURL.absoluteString] ?
                           responseObject : anotherResponse;
            return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
        }];
    });

    afterEach((id)^
    {
        [storage cleanAllObjects];
        [OHHTTPStubs removeAllStubs];
    });

    it(@"should remove object from memory, but keep it at file", ^
    {
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
        // loading object and check file and memory
        __block BOOL isFileExists = YES, isObjectInMemory = YES;
        [storage loadObjectWithURL:objectURL keepInMemory:YES callback:^(id object, NSError *error)
        {
            // remove object
            [storage cleanObjectWithURL:objectURL];
            // check is exist
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

    it(@"should remove any object from memory storage if max count reached", ^
    {
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
        in_time(anotherObject) should equal(anotherResponse);
    });

    it(@"should store more objects in memory storage if new max count greater then previous", ^
    {
        // loading object
        NSURL *anotherURL = [NSURL URLWithString:@"http://example.com/another_object"];
        NSURL *objectLocalURL = [APStoragePathHelper storageURLForNetworkURL:objectURL];
        NSURL *anotherLocalURL = [APStoragePathHelper storageURLForNetworkURL:anotherURL];
        __block id checkObject = [[NSObject alloc] init];
        __block id anotherObject = nil;
        storage.maxObjectCount = 2;
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
        in_time(checkObject) should_not be_nil;
        in_time(checkObject) should equal(responseObject);
        in_time(anotherObject) should_not be_nil;
        in_time(anotherObject) should equal(anotherObject);
    });

    it(@"should remove memory objects on memory warning", ^
    {
        // loading object
        NSURL *anotherURL = [NSURL URLWithString:@"http://example.com/another_object"];
        NSURL *objectLocalURL = [APStoragePathHelper storageURLForNetworkURL:objectURL];
        NSURL *anotherLocalURL = [APStoragePathHelper storageURLForNetworkURL:anotherURL];
        __block id checkObject = [[NSObject alloc] init];
        __block id anotherObject = [[NSObject alloc] init];
        [storage loadObjectWithURL:objectURL keepInMemory:YES callback:^(id object, NSError *error)
        {
            [storage loadObjectWithURL:anotherURL keepInMemory:YES
                              callback:^(id object, NSError *error)
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
        }];
        in_time(checkObject) should be_nil;
        in_time(anotherObject) should be_nil;
    });
});

SPEC_END