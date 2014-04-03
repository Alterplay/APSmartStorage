//
//  Deprecated.h
//  APSmartStorage
//
//  Created by Alexey Belkevich on 4/3/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#ifndef APSmartStorageSpec_Deprecated_h
#define APSmartStorageSpec_Deprecated_h

#define AP_DEPRECATED(_useInstead) __attribute__((deprecated("Use " #_useInstead " instead")))

#endif
