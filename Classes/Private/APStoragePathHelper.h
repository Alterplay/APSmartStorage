//
//  APStoragePathHelper.h
//  APSmartStorage
//
//  Created by Alexey Belkevich on 1/17/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APStoragePathHelper : NSObject

+ (NSURL *)storageURLForNetworkURL:(NSURL *)networkURL;
+ (NSURL *)storageDirectoryURL;

@end
