//
//  NSStringCamelizeSpec.m
//  pf
//
//  Created by Алексей Карасев on 05/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import "Kiwi.h"
#import <MagicalRecord/MagicalRecord.h>
#import "NSString+Camelize.h"

SPEC_BEGIN(NSStringCamelizeSpec)

describe (@"NSString+Camelize", ^{
    
    describe (@"PF_camelizedString", ^{
        it (@"camelizes the dash string", ^{
            [[[@"account_group_id" PF_camelizedString] should] equal:@"accountGroupId"];
            [[[@"account" PF_camelizedString] should] equal:@"account"];
        });
        
        it (@"raises InvalidCamelizeFormat if the string is not in dash format", ^{
            [[theBlock(^{
                [@"accountGroup" PF_camelizedString];
            }) should] raiseWithName:@"InvalidCamelizeFormat"];
            [[theBlock(^{
                [@"account_" PF_camelizedString];
            }) should] raiseWithName:@"InvalidCamelizeFormat"];
            [[theBlock(^{
                [@"_account" PF_camelizedString];
            }) should] raiseWithName:@"InvalidCamelizeFormat"];
        });
    });
    
    describe (@"PF_unCamelizedString", ^{
        it (@"dashes the camelized string", ^{
            [[[@"accountGroupId" PF_unCamelizedString] should] equal:@"account_group_id"];
            [[[@"account" PF_unCamelizedString] should] equal:@"account"];
            [[[@"Account" PF_unCamelizedString] should] equal:@"account"];
        });
        
        it (@"raises InvalidCamelizeFormat if the string is not in camel format", ^{
            [[theBlock(^{
                [@"account_group" PF_unCamelizedString];
            }) should] raiseWithName:@"InvalidCamelizeFormat"];
        });
    });
    
});

SPEC_END
