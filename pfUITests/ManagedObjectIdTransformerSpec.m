//
//  ManagedObjectIdTransformerSpec.m
//  pf
//
//  Created by Алексей Карасев on 10/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import "Kiwi.h"
#import <MagicalRecord/MagicalRecord.h>
#import "TestModel.h"

SPEC_BEGIN(ManagedObjectIdTransformerSpec)

describe (@"ManagedObjectIdTransformer", ^{
    
    beforeEach(^{
        [MagicalRecord cleanUp];
        [MagicalRecord setDefaultModelNamed:@"specModel.momd"];
        [MagicalRecord setupCoreDataStackWithStoreNamed:@"test.sqlite"];
    });
    
    afterEach(^{
        NSURL* url = [NSPersistentStore MR_urlForStoreName:@"test.sqlite"];
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        [MagicalRecord cleanUp];
    });
    
    it (@"correctly stores the id of ManagedObject", ^{
        TestGroup* group = [TestGroup MR_createEntity];
        group.name = @"test1";
        [[NSManagedObjectContext MR_defaultContext] save:nil];
        [[NSManagedObjectContext MR_rootSavingContext] save:nil];
        
        TestGroup* group1 = [TestGroup MR_findFirst];
        [[group1.name should] equal:@"test1"];
        
        NSManagedObjectID* groupId = group1.objectID;
        TestDataLog* dataLog = [TestDataLog MR_createEntity];
        dataLog.localId = groupId;
        [[NSManagedObjectContext MR_defaultContext] save:nil];
        [[NSManagedObjectContext MR_rootSavingContext] save:nil];
        
        TestDataLog* dataLog1 = [TestDataLog MR_findFirst];
        [[dataLog1.localId should] equal: groupId];
        
        NSManagedObjectContext* context = [NSManagedObjectContext MR_context];
        TestGroup* group2 = [context existingObjectWithID:dataLog.localId error:nil];
        [[group2.name should] equal:@"test1"];
    });
    
    it (@"raises an exception if passed not an id", ^{
        [[theBlock(^{
            TestDataLog* dataLog = [TestDataLog MR_createEntity];
            dataLog.localId = @"123";
            [[NSManagedObjectContext MR_defaultContext] save:nil];
            [[NSManagedObjectContext MR_rootSavingContext] save:nil];
        }) should] raise];
    });
    
    it (@"raises an exception if passed a temporary id", ^{
        [[theBlock(^{
            TestGroup* group = [TestGroup MR_createEntity];
            TestDataLog* dataLog = [TestDataLog MR_createEntity];
            dataLog.localId = group.objectID;
            [[NSManagedObjectContext MR_defaultContext] save:nil];
            [[NSManagedObjectContext MR_rootSavingContext] save:nil];
        }) should] raise];
    });
});

SPEC_END