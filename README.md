<img src="https://dl.dropboxusercontent.com/u/2334198/APSmartStorage-git-teaser.png">

APSmartStorage helps to get data from network and automatically caches data on disk or in memory in a smart configurable way. Here is how the `APSmartStorage` flow diagram looks like:
<img src="https://dl.dropboxusercontent.com/u/2334198/APSmartStorage-git-illustration.png">

#### Features
* Load cached object from **memory** by URL
* Load cached object from **file** by URL
* Load object from **network** by URL
* Store loaded object to **file**
* Store loaded object to **memory**
* Parse loaded data from network (for instance, [NSData](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSData_Class/Reference/Reference.html) to [UIImage](https://developer.apple.com/library/ios/documentation/uikit/reference/UIImage_Class/Reference/Reference.html))
* Automatically purge memory cache on **memory warning**
* Set max object count to keep in memory to prevent memory overflow
* Set custom [NSURLSessionConfiguration](https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSURLSessionConfiguration_class/Reference/Reference.html#//apple_ref/doc/c_ref/NSURLSessionConfiguration)

#### Installation
Add `APSmartStorage` pod to Podfile

#### Using

###### Example
Here is example how to use `APSmartStorage` to store images
```objective-c
// setup data parsing block
APSmartStorage.sharedInstance.parsingBlock = ^(NSData *data, NSURL *url)
{
    return [UIImage imageWithData:data scale:UIScreen.mainScreen.scale];
};
...
// show some progress/activity
...
// load object with URL
[APSmartStorage.sharedInstance loadObjectWithURL:imageURL callback:(id object, NSError *error)
{
    // hide progress/activity
    if (error)
    {
        // show error
    }
    else 
    {
        // do something with object
    }
}];
```

###### Update stored object
Objects stored at files could become outdated after some time, and application should reload it from network
```objective-c
[APSmartStorage.sharedInstance reloadObjectWithURL:objectURL callback:(id object, NSError *error)
{
    if (error)
    {
        // show error and do something like use outdated version of object
    }
    else
    {
        // do something with object
    }
}];
```

###### Remove objects from memory
```objective-c
// remove object from memory
[APSmartStorage.sharedInstance removeObjectWithURL:objectURL];
// remove all objects form memory
[APSmartStorage.sharedInstance removeAllObjects];
```

###### Remove object from memory and delete file storage
```objective-c
// remove object from memory and remove file
[APSmartStorage.sharedInstance cleanObjectWithURL:objectURL];
// remove all objects from memory and all storage files
[APSmartStorage.sharedInstance cleanAllObjects];
```

###### Parse network and file data
If `parsingBlock` doesn't set you will receive raw `NSData` downloaded from network or read from file. So you should set one in most cases. If you need to parse data of different formats it will be a bit more complicated:
```objective-c
APSmartStorage.sharedInstance.parsingBlock = ^(NSData *data, NSURL *url)
{
    // is URL of image
    if ([url isImageURL])
    {
        return [UIImage imageWithData:data scale:UIScreen.mainScreen.scale];
    }
    // this is URL of something else
    else
    {
        return [SomeObject objectWithData:data];
    }
};
```

###### Set max objects count to keep in memory
If max object count reached random object will be removed from memory before add next one
```objective-c
APSmartStorage.sharedInstance.maxObjectCount = 10;
```

###### Setup custom `NSURLSessionConfiguration`
```objective-c
APSmartStorage.sharedInstance.sessionConfiguration = sessionConfiguration;
```

=======================
[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/d6acc1315fe3f24e01e0a3a77b220f59 "githalytics.com")](http://githalytics.com/Alterplay/APSmartStorage)
If you have improvements or concerns, feel free to post [an issue](https://github.com/Alterplay/APSmartStorage/issues) and write details.

[Check out](https://github.com/Alterplay) all Alterplay's GitHub projects.
[Email us](mailto:hello@alterplay.com?subject=From%20GitHub%20APSmartStorage) with other ideas and projects.
