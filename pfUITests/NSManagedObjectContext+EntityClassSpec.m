//
//  NSManagedObjectContextEntityClassSpec.m
//  pf
//
//  Created by Алексей Карасев on 06/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import "Kiwi.h"
#import <MagicalRecord/MagicalRecord.h>
#import "TestModel.h"
#import "NSManagedObjectContext+EntityClass.h"

SPEC_BEGIN(NSManagedObjectContextEntityClassSpec)

describe (@"NSManagedObjectContextEntityClass", ^{
    __block NSManagedObjectContext* context;
    
    beforeEach(^{
        [MagicalRecord cleanUp];
        [MagicalRecord setDefaultModelNamed:@"specModel.momd"];
        [MagicalRecord setupCoreDataStackWithInMemoryStore];
        context = [NSManagedObjectContext MR_defaultContext];
    });
    
    afterEach(^{
        [MagicalRecord cleanUp];
    });
    
    describe (@"entityDescriptionWithName", ^{
        it (@"returns the entity description", ^{
            NSManagedObjectModel *managedObjectModel = [[context persistentStoreCoordinator] managedObjectModel];
            NSEntityDescription *entityDesc = [[managedObjectModel entitiesByName] objectForKey:@"TestGroup"];
            [[entityDesc should] equal:[context PF_entityDescriptionWithName:@"TestGroup"]];
        });
    });
    
    describe (@"classFromEntityName", ^{
        it (@"returns a class for specified entity", ^{
            [[[context PF_classWithEntityName:@"TestGroup"] should] equal:[TestGroup class]];
        });
        
        it (@"raises EntityNotFound if the entity doesn't exist", ^{
            [[theBlock(^{
                [context PF_classWithEntityName:@"dfjglsdj"];
            }) should] raiseWithName:@"EntityNotFound"];
        });
    });
    
});

SPEC_END