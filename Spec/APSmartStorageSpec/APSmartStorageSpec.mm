//
//  APSmartStorageSpec.mm
//  APSmartStorageSpec
//
//  Created by Alexey Belkevich on 1/16/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(APSmartStorageSpec)

describe(@"APSmartStorage", ^
{
    it(@"should fail spec", ^
    {
        YES should equal(NO);
    });
});

SPEC_END
