//
//  WebSyncJsonConverterSpec.m
//  pf
//
//  Created by Алексей Карасев on 05/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import "Kiwi.h"
#import <MagicalRecord/MagicalRecord.h>
#import "TestModel.h"
#import "WebCoreDataFacade.h"

SPEC_BEGIN(WebCoreDataFacadeSpec)

describe (@"WebCoreDataFacade", ^{
    
    beforeEach(^{
        [MagicalRecord cleanUp];
        [MagicalRecord setDefaultModelNamed:@"specModel.momd"];
        [MagicalRecord setupCoreDataStackWithInMemoryStore];
    });
    
    afterEach(^{
        [MagicalRecord cleanUp];
    });
    
    it (@"is a Singleton", ^{
        id obj = [WebCoreDataFacade sharedInstance];
        [[obj should] beKindOfClass:[WebCoreDataFacade class]];
    });
    
    describe (@"managedObjectToJson:", ^{
        it (@"converts managed object to JSON string. To one relationships transforms into ids with uncamelized case", ^{
            TestGroup* group = [TestGroup MR_createEntity];
            group.name = @"group1";
            group.longNameAttribute = @"lna1";
            TestParent* user = [TestParent MR_createEntity];
            user.id = @"20";
            [user addTestGroupsObject: group];
            NSDictionary* result = [[WebCoreDataFacade sharedInstance] managedObjectToDictionary:group];
            NSDictionary* benchmark = @{@"name":@"group1", @"test_parent_id":@"20", @"long_name_attribute":@"lna1"};
            [[benchmark should] equal:result];
        });
    });
    
    describe (@"dictionaryToJson", ^{
        it (@"converts a dictionary to JSON data", ^{
            NSDictionary* dict = @{@"name":@"test", @"user":@{@"user_id":@"1"}};
            NSString* benchmarkString = @"{\"name\":\"test\",\"user\":{\"user_id\":\"1\"}}";
            NSData* benchmark = [benchmarkString dataUsingEncoding:NSUTF8StringEncoding];
            NSData* result  = [[WebCoreDataFacade sharedInstance] dictionaryToJsonString:dict];
            [[result should] equal:benchmark];
        });
    });
});
    
SPEC_END