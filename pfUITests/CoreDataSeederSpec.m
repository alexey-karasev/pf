//
//  CoreDataSeederSpec.m
//  pf
//
//  Created by Алексей Карасев on 01/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import "Kiwi.h"
#import <MagicalRecord/MagicalRecord.h>
#import "TestModel.h"
#import "CoreDataSeeder.h"
#import "ContextManager.h"

SPEC_BEGIN(CoreDataSeederSpec)

describe (@"CoreDataSeeder", ^{
    
    beforeEach(^{
        [MagicalRecord cleanUp];
        [MagicalRecord setDefaultModelNamed:@"specModel.momd"];
        [MagicalRecord setupCoreDataStackWithInMemoryStore];
    });
    
    afterAll(^{
        [MagicalRecord cleanUp];
    });
    
    let (seeder, ^{
        return [[CoreDataSeeder alloc] init];
    });

    describe (@"initWithContext", ^{
        it (@"sets the context property", ^{
            NSManagedObjectContext *context = [NSManagedObjectContext MR_context];
            CoreDataSeeder* seeder = [[CoreDataSeeder alloc] initWithContext:context];
            [[seeder.context should] equal:context];
        });
    });
    
    describe (@"context", ^{
        it (@"returns a defaultContext if not set", ^{
            [[seeder.context should] equal:[[ContextManager sharedInstance] mainContext]];
        });
    });
    
    describe (@"importEntity:FromData:", ^{
        it (@"imports NSData (id json text is array) into default MR context", ^{
            NSString* text = @"[{\"name\": \"test1\", \"id\": \"1\"}, {\"name\": \"test2\", \"id\": \"2\"}]";
            NSData* data = [text dataUsingEncoding:NSUTF8StringEncoding];
            [seeder importEntity:@"TestGroup" FromData:data];
            NSArray* result = [TestGroup MR_findAll];
            [[result should] haveCountOf:2];
            for (id obj in result) {
                [[obj should] beKindOfClass:[TestGroup class]];
                TestGroup* group = (TestGroup*) obj;
                if ([group.id integerValue] == 1) {
                    [[group.name should] equal:@"test1"];
                } else if ([group.id integerValue] == 2) {
                    [[group.name should] equal:@"test2"];
                } else {
                    [[theValue(0) should] equal:theValue(1)];
                }
            }
        });
        
        it (@"imports NSData (id json text is one object) into default MR context", ^{
            NSString* text = @"{\"name\": \"test1\", \"id\": \"1\"}";
            NSData* data = [text dataUsingEncoding:NSUTF8StringEncoding];
            [seeder importEntity:@"TestGroup" FromData:data];
            NSArray* result = [TestGroup MR_findAll];
            [[result should] haveCountOf:1];
            [[result[0] should] beKindOfClass:[TestGroup class]];
            TestGroup* group = (TestGroup*) result[0];
            [[group.id should] equal:@"1"];
            [[group.name should] equal:@"test1"];
        });
        
        it (@"Throws EntityNotFound exception if Entity doesn't exist", ^{
            [[theBlock(^{
                NSString* text = @"{\"name\": \"test1\", \"id\": \"1\"}";
                NSData* data = [text dataUsingEncoding:NSUTF8StringEncoding];
                [seeder importEntity:@"sdfhksjdfh" FromData:data];
            }) should] raiseWithName:@"EntityNotFound"];
        });
        
        it (@"Raises InvalidJSONFormat exception if json is invalid", ^{
            [[theBlock(^{
                NSString* text = @"sjdf{}fkdl[[";
                NSData* data = [text dataUsingEncoding:NSUTF8StringEncoding];
                [seeder importEntity:@"AccountGroup" FromData:data];
            }) should] raiseWithName:@"InvalidJSONFormat"];
        });
    });
    
    describe (@"importEntity:FromResource:", ^{
        it (@"imports the data from resource", ^{
            [seeder importEntity:@"TestGroup" FromResource:@"Accounts"];
            NSArray* result = [TestGroup MR_findAll];
            [[result should] haveCountOfAtLeast:1];
        });
        
        it (@"throws an Exception if the resource doesn't exist", ^{
            [[theBlock(^{
                [seeder importEntity:@"AccountGroup" FromResource:@"sdjfhskjdfh"];
            }) should] raise];
        });
    });
    
});

SPEC_END