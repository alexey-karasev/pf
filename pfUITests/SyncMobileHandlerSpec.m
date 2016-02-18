//
//  SyncMobileInsertHandlerSpec.m
//  pf
//
//  Created by Алексей Карасев on 10/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import "Kiwi.h"
#import <MagicalRecord/MagicalRecord.h>
#import "TestModel.h"
#import "Model.h"
#import "Nocilla.h"
#import "SyncMobileHandler.h"
#import "RequestFactory.h"
#import "ContextManager.h"
#import "WebServiceFetcher.h"

@implementation WebServiceFetcher (UnitTest)

+ (NSArray*) retryDelaysPattern {
    return @[@0.01];
}

@end

@interface RequestFactory(UnitTest)
@property (nonatomic, strong, readwrite) NSString *host;
@end

SPEC_BEGIN(SyncMobileHandlerSpec)

describe (@"SyncMobileHandler", ^{
    
    beforeEach(^{
        [[LSNocilla sharedInstance] start];
        [MagicalRecord cleanUp];
        [MagicalRecord setupCoreDataStackWithStoreNamed:@"test.sqlite"];
    });
    
    afterEach(^{
        NSURL* url = [NSPersistentStore MR_urlForStoreName:@"test.sqlite"];
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        [MagicalRecord cleanUp];
        [[ContextManager sharedInstance] resetRootSyncContext];
        [[LSNocilla sharedInstance] stop];
        [[LSNocilla sharedInstance] clearStubs];
    });
    
    NSString* (^methodToURLString)(NSString*) = ^NSString* (NSString* method) {
        NSMutableString* methodURL = [[NSMutableString alloc] initWithString: @"http://localhost:3000/account_groups"];
        if (![method isEqualToString:@"POST"]) {
            [methodURL appendString:@"/2"];
        }
        return methodURL;
    };
    
    NSString* (^commandToMethod)(NetworkCommand) = ^NSString* (NetworkCommand command) {
        NSDictionary* REST = @{
                               @(NetworkCommandCreate) : @"POST",
                               @(NetworkCommandUpdate) : @"PATCH",
                               @(NetworkCommandDelete) : @"DELETE"};
        return REST[@(command)];
    };
    
    void (^stubAttributesRequest)(NSString*) = ^void (NSString* method) {
        NSString* methodURL = methodToURLString(method);
        if ([method isEqualToString:@"DELETE"]) {
            stubRequest(method, methodURL).
            andReturn(200).
            withHeaders(@{@"Content-Type": @"application/json"}).
            withBody([@"{\"id\":\"2\",\"name\":\"foo\",\"data_log_id\":\"10\"}" dataUsingEncoding:NSUTF8StringEncoding]);
        } else {
            stubRequest(method, methodURL).
            withBody([@"{\"name\":\"foo\"}" dataUsingEncoding:NSUTF8StringEncoding]).
            andReturn(200).
            withHeaders(@{@"Content-Type": @"application/json"}).
            withBody([@"{\"id\":\"2\",\"name\":\"foo\",\"data_log_id\":\"10\"}" dataUsingEncoding:NSUTF8StringEncoding]);
        }
    };
    
    void (^stubSyncRequest)() = ^{
        stubRequest(@"PATCH", @"http://localhost:3000/data_logs/10").
        withBody([@"{\"status\":1000}" dataUsingEncoding:NSUTF8StringEncoding]).
        andReturn(200).
        withHeaders(@{@"Content-Type": @"application/json"}).
        withBody([@"{\"id\":\"10\"}" dataUsingEncoding:NSUTF8StringEncoding]);
    };
    
    void (^setupCoreData)(NetworkCommand) = ^void (NetworkCommand command) {
        AccountGroup* group = [AccountGroup MR_createEntity];
        DataLog* dataLog = [DataLog MR_createEntity];
        if (command == NetworkCommandUpdate) {
            group.name = @"bar";
            group.id = @"2";
        } else if (command == NetworkCommandCreate){
        group.name = @"foo";
        } else if (command == NetworkCommandDelete){
            group.name = @"foo";
            group.id = @"2";
        }
        [[NSManagedObjectContext  MR_defaultContext] save:nil];
        [[NSManagedObjectContext  MR_rootSavingContext] save:nil];
        dataLog.command = @(command);
        dataLog.entityTitle = @"AccountGroup";
        dataLog.attributes = @"{\"name\":\"foo\"}";
        dataLog.status = @(SyncMobileStatusInitial);
        dataLog.origin = @(DataLogOriginMobile);
        dataLog.localId = group.objectID;
        dataLog.globalId = group.id;
        [[NSManagedObjectContext  MR_defaultContext] save:nil];
        [[NSManagedObjectContext  MR_rootSavingContext] save:nil];
    };
    
    void (^testForCommand)(NetworkCommand) = ^void (NetworkCommand command) {
        stubAttributesRequest(commandToMethod(command));
        stubSyncRequest();
        setupCoreData(command);
        DataLog* dataLog = [DataLog MR_findFirst];
        NSManagedObjectID* dataId = [dataLog objectID];
        SyncMobileHandler* handler = [[SyncMobileHandler alloc] initWithDataLogId:dataId];
        [handler handle];
        [[expectFutureValue(@(handler.status)) shouldEventually] equal:@(SyncMobileStatusSynced)];
        [[expectFutureValue([DataLog MR_findFirst].status) shouldEventually] equal:@(SyncMobileStatusSynced)];
        [[expectFutureValue([DataLog MR_findFirst].id) shouldEventually] equal:@"10"];
        if (command == NetworkCommandCreate) {
            [[expectFutureValue([DataLog MR_findFirst].globalId) shouldEventually] equal:@"2"];
            [[expectFutureValue([AccountGroup MR_findFirst].id) shouldEventually] equal:@"2"];
        }

    };
    

    
    describe (@"handle:", ^{
        context (@"Create command", ^{
            it (@"sends requests to server and syncs", ^{
                testForCommand(NetworkCommandCreate);
            });
        });
        context (@"Update command", ^{
            it (@"sends requests to server and syncs", ^{
                testForCommand(NetworkCommandUpdate);
            });
        });
        context (@"Delete command", ^{
            it (@"sends requests to server and syncs", ^{
                testForCommand(NetworkCommandDelete);
            });
        });
        context (@"Server is unreachable", ^{
            it (@"Sets the status to SyncMobileStatusFailedAttributesUpload", ^{
                [@[@(NetworkCommandCreate), @(NetworkCommandUpdate), @(NetworkCommandDelete)] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NetworkCommand command = [(NSNumber*)obj integerValue];
                    NSString* method = commandToMethod(command);
                    NSString* url = methodToURLString(method);
                    stubRequest(method, url).
                    withBody(@"{\"name\":\"foo\"}").
                    andFailWithError([NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:nil]);
                    setupCoreData(command);
                    DataLog* dataLog = [DataLog MR_findFirst];
                    NSManagedObjectID* dataId = [dataLog objectID];
                    SyncMobileHandler* handler = [[SyncMobileHandler alloc] initWithDataLogId:dataId];
                    [handler handle];
                    [[expectFutureValue(@(handler.status)) shouldEventually] equal:@(SyncMobileStatusFailedAttributesUpload)];
                    
                }];
            });
        });
        
        context (@"Server becomes unreachable after the attributes upload", ^{
            it (@"Sets the status to SyncMobileStatusFailedSyncUpload", ^{
//                [@[@(NetworkCommandCreate), @(NetworkCommandUpdate), @(NetworkCommandDelete)] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    NetworkCommand command = [(NSNumber*)obj integerValue];
                NetworkCommand command = NetworkCommandCreate;
                    NSString* method = commandToMethod(command);
                    stubAttributesRequest(method);
                    stubRequest(@"PATCH", @"http://localhost:3000/data_logs/10").
                    withBody([@"{\"status\":1000}" dataUsingEncoding:NSUTF8StringEncoding]).
                    andFailWithError([NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:nil]);
                    setupCoreData(command);
                    DataLog* dataLog = [DataLog MR_findFirst];
                    NSManagedObjectID* dataId = [dataLog objectID];
                    SyncMobileHandler* handler = [[SyncMobileHandler alloc] initWithDataLogId:dataId];
                    [handler handle];

                    [[expectFutureValue(@(handler.status)) shouldEventually] equal:@(SyncMobileStatusFailedSyncUpload)];
//                }];
            });
        });
    });
    
});

SPEC_END
