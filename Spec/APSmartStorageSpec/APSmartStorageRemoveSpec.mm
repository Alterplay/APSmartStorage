//
//  APSmartStorageRemoveSpec.mm
//  APSmartStorageSpec
//
//  Created by Alexey Belkevich on 1/22/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "CedarAsync.h"
#import "APSmartStorage.h"
#import "APMemoryStorage.h"
#import "OHHTTPStubs+AllRequests.h"

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
    __block NSURL *objectURL1, *objectURL2;
    __block NSString *filePath1, *filePath2;
    __block id responseObject1, responseObject2;

    beforeEach((id)^
    {
        storage = [[APSmartStorage alloc] initWithCustomSessionConfiguration:nil
                                                              maxObjectCount:1];
        objectURL1 = [NSURL URLWithString:@"http://example.com/object_data1"];
        objectURL2 = [NSURL URLWithString:@"http://example.com/object_data2"];
        responseObject1 = [@"response 1" dataUsingEncoding:NSUTF8StringEncoding];
        responseObject2 = [@"response 2" dataUsingEncoding:NSUTF8StringEncoding];
        // mocking network request
        [OHHTTPStubs stubAllRequestsWithStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request)
        {
            NSData *data = [request.URL.absoluteString isEqualToString:objectURL1.absoluteString] ?
                           responseObject1 : responseObject2;
            return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
        }];
        // create dir
        NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *dirPath = [array.firstObject stringByAppendingPathComponent:@"APSmartStorage"];
        [NSFileManager.defaultManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES
                                                 attributes:nil error:nil];
        // file path
        filePath1 = [dirPath stringByAppendingPathComponent:@"d9bd5f7d33abe0592f8c3bcdc2ea2f05"];
        filePath2 = [dirPath stringByAppendingPathComponent:@"dc549a2ae54caf4eb5f9d1967a36f61d"];
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
        [storage loadObjectWithURL:objectURL1 keepInMemory:YES callback:^(id object, NSError *error)
        {
            // remove object
            [storage removeObjectWithURL:objectURL1];
            // check existence
            isFileExists = [NSFileManager.defaultManager fileExistsAtPath:filePath1];
            NSURL *url = [NSURL fileURLWithPath:filePath1];
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
        [storage loadObjectWithURL:objectURL1 keepInMemory:YES callback:^(id object, NSError *error)
        {
            // remove object
            [storage cleanObjectWithURL:objectURL1];
            // check is exist
            NSURL *url = [NSURL fileURLWithPath:filePath1];
            [storage.memoryStorage objectForLocalURL:url callback:^(id objectAfterRemove)
            {
                isFileExists = [NSFileManager.defaultManager fileExistsAtPath:filePath1];
                isObjectInMemory = (objectAfterRemove != nil);
            }];
        }];
        in_time(isFileExists) should equal(NO);
        in_time(isObjectInMemory) should equal(NO);
    });

    it(@"should remove any object from memory storage if max count reached", ^
    {
        // loading object
        __block id object1 = [[NSObject alloc] init];
        __block id object2 = nil;
        [storage loadObjectWithURL:objectURL1 keepInMemory:YES callback:nil];
        [storage loadObjectWithURL:objectURL2 keepInMemory:YES callback:^(id object, NSError *error)
        {
            NSURL *objectLocalURL1 = [NSURL fileURLWithPath:filePath1];
            NSURL *objectLocalURL2 = [NSURL fileURLWithPath:filePath2];
            [storage.memoryStorage objectForLocalURL:objectLocalURL1 callback:^(id obj)
            {
                object1 = obj;
            }];
            [storage.memoryStorage objectForLocalURL:objectLocalURL2 callback:^(id obj)
            {
                object2 = obj;
            }];
        }];
        in_time(object1) should be_nil;
        in_time(object2) should_not be_nil;
        in_time(object2) should equal(responseObject2);
    });

    it(@"should store more objects in memory storage if new max count greater then previous", ^
    {
        // loading object
        __block id object1 = [[NSObject alloc] init];
        __block id object2 = nil;
        storage.maxObjectCount = 2;
        [storage loadObjectWithURL:objectURL1 keepInMemory:YES callback:nil];
        [storage loadObjectWithURL:objectURL2 keepInMemory:YES callback:^(id object, NSError *error)
        {
            NSURL *objectLocalURL1 = [NSURL fileURLWithPath:filePath1];
            NSURL *objectLocalURL2 = [NSURL fileURLWithPath:filePath2];
            [storage.memoryStorage objectForLocalURL:objectLocalURL1 callback:^(id object)
            {
                object1 = object;
            }];
            [storage.memoryStorage objectForLocalURL:objectLocalURL2 callback:^(id object)
            {
                object2 = object;
            }];
        }];
        in_time(object1) should_not be_nil;
        in_time(object1) should equal(responseObject1);
        in_time(object2) should_not be_nil;
        in_time(object2) should equal(responseObject2);
    });

    it(@"should remove memory objects on memory warning", ^
    {
        // loading object
        __block id object1 = [[NSObject alloc] init];
        __block id object2 = [[NSObject alloc] init];
        [storage loadObjectWithURL:objectURL1 keepInMemory:YES callback:^(id object, NSError *error)
        {
            [storage loadObjectWithURL:objectURL2 keepInMemory:YES callback:^(id obj, NSError *err)
            {
                [storage didReceiveMemoryWarning:nil];
                NSURL *objectLocalURL1 = [NSURL fileURLWithPath:filePath1];
                NSURL *objectLocalURL2 = [NSURL fileURLWithPath:filePath2];
                [storage.memoryStorage objectForLocalURL:objectLocalURL1 callback:^(id obj1)
                {
                    object1 = obj1;
                }];
                [storage.memoryStorage objectForLocalURL:objectLocalURL2 callback:^(id obj2)
                {
                    object2 = obj2;
                }];
            }];
        }];
        in_time(object1) should be_nil;
        in_time(object2) should be_nil;
    });
});

SPEC_END