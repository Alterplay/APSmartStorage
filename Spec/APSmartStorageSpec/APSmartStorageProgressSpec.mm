//
//  APSmartStorageProgressSpec.mm
//  APSmartStorageSpec
//
//  Created by Alexey Belkevich on 4/7/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "CedarAsync.h"
#import "APSmartStorage+Memory.h"
#import "OHHTTPStubs+AllRequests.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(APSmartStorageProgressSpec)

describe(@"APSmartStorage", ^
{
    __block APSmartStorage *storage;
    __block NSURL *objectURL;
    __block NSString *filePath;
    __block id responseObject;

    beforeEach((id)^
    {
        storage = [[APSmartStorage alloc] init];
        objectURL = [NSURL URLWithString:@"http://example.com/object_data"];
        responseObject = [@"APSmartStorage string" dataUsingEncoding:NSUTF8StringEncoding];
        // create dir
        NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *dirPath = [array.firstObject stringByAppendingPathComponent:@"APSmartStorage"];
        [NSFileManager.defaultManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES
                                                 attributes:nil error:nil];
        // file path
        filePath = [dirPath stringByAppendingPathComponent:@"327fa8f97ba3bbd262a1768080d93f46"];
        // mocking network request
        [OHHTTPStubs stubAllRequestsWithResponseData:responseObject];
    });

    afterEach((id)^
    {
        [storage removeAllFromStorage];
        [OHHTTPStubs removeAllStubs];
    });

    it(@"should receive 100% progress on load object with URL from network", ^
    {
        __block NSUInteger progress = 0;
        [storage loadObjectWithURL:objectURL storeInMemory:YES progress:^(NSUInteger percents)
        {
            progress = percents;
        }               completion:nil];
        in_time(progress) should equal(100);
    });

    it(@"should receive 100% progress on load object with URL from file", ^
    {
        // remove network mock
        [OHHTTPStubs removeAllStubs];
        [OHHTTPStubs stubAllRequestsWithNetworkDown];
        // mocking file
        NSURL *url = [NSURL fileURLWithPath:filePath];
        [responseObject writeToURL:url atomically:YES];
        // loading object
        __block NSUInteger progress = 0;
        [storage loadObjectWithURL:objectURL storeInMemory:YES progress:^(NSUInteger percents)
        {
            progress = percents;
        }               completion:nil];
        in_time(progress) should equal(100);
    });

    it(@"should receive 100% progress on load object from memory storage", ^
    {
        __block NSUInteger progress = 0;
        [storage loadObjectWithURL:objectURL completion:^(id object, NSError *error)
        {
            // remove network mock
            [OHHTTPStubs removeAllStubs];
            [OHHTTPStubs stubAllRequestsWithNetworkDown];
            // remove file
            [NSFileManager.defaultManager removeItemAtPath:filePath error:nil];
            // loading object from memory
            [storage loadObjectWithURL:objectURL storeInMemory:YES progress:^(NSUInteger percents)
            {
                progress = percents;
            }               completion:nil];
        }];
        in_time(progress) should equal(100);
    });
});

SPEC_END