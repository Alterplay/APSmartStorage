//
//  APSmartStorageFileSpec.mm
//  APSmartStorageSpec
//
//  Created by Alexey Belkevich on 1/22/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "CedarAsync.h"
#import "APSmartStorage.h"
#import "OHHTTPStubs+AllRequests.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface APSmartStorage (Private)
- (void)objectFromMemoryWithURL:(NSURL *)objectURL callback:(void (^)(id object))callback;
@end

SPEC_BEGIN(APSmartStorageFileSpec)

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

    it(@"should load object from network, store it to file and keep it in memory", ^
    {
        __block BOOL isFileExists = NO;
        __block id checkObject = nil;
        [storage loadObjectWithURL:objectURL callback:^(id object, NSError *error)
        {
            isFileExists = [NSFileManager.defaultManager fileExistsAtPath:filePath];
            [storage objectFromMemoryWithURL:objectURL callback:^(id obj)
            {
                checkObject = obj;
            }];
        }];
        in_time(isFileExists) should equal(YES);
        in_time(checkObject) should equal(responseObject);
    });

    it(@"should rewrite file on reload", ^
    {
        // mocking file
        [responseObject writeToFile:filePath atomically:YES];
        // mocking network request
        NSData *anotherData = [@"another response" dataUsingEncoding:NSUTF8StringEncoding];
        [OHHTTPStubs removeAllStubs];
        [OHHTTPStubs stubAllRequestsWithResponseData:anotherData];
        // loading object
        __block id checkData;
        [storage reloadObjectWithURL:objectURL callback:^(id object, NSError *error)
        {
            checkData = [NSData dataWithContentsOfFile:filePath];
        }];
        in_time(checkData) should_not be_nil;
        in_time(checkData) should equal(anotherData);
    });
});

SPEC_END