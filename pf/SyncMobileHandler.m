//
//  SyncMobileInsertHandler.m
//  pf
//
//  Created by Алексей Карасев on 08/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import "SyncMobileHandler.h"
#import "WebServiceFetcher.h"
#import <MagicalRecord/MagicalRecord.h>
#import "ContextManager.h"
#import "WebServiceFetcher.h"

@interface SyncMobileHandler ()
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) DataLog *dataLog;
@property (nonatomic, strong) WebServiceFetcher *fetcher;
@property (nonatomic, readwrite) SyncMobileStatus status;
@end

@implementation SyncMobileHandler

- (NSManagedObjectContext*) context {
    if (!_context) _context = [[ContextManager sharedInstance] createSyncContext];
    return _context;
}

- (SyncMobileStatus) status {
    return [self.dataLog.status integerValue];
}

- (void) setStatus:(SyncMobileStatus) status {
    [self willChangeValueForKey:@"status"];
    self.dataLog.status = @(status);
    [self didChangeValueForKey:@"status"];
}

- (instancetype) initWithDataLogId: (NSManagedObjectID*) dataLogId {
    self = [super init];
    NSError* error;
    _dataLog = [self.context existingObjectWithID:dataLogId error:&error];
    if (error) {
        [NSException raise:@"InvalidArgumentsException" format:@"Failed to fetch data log with id: %@", dataLogId];
    }
    return self;
}

- (void) handle {
    NetworkCommand command = [self.dataLog.command integerValue];
    NSError* error;
    NSDictionary* attributes = [NSJSONSerialization JSONObjectWithData:[self.dataLog.attributes dataUsingEncoding: NSUTF8StringEncoding] options:kNilOptions error:&error];
    if (error) {
        [NSException raise:@"InvalidAttributesFormat" format:@"Failed to parse attributes: %@", self.dataLog.attributes];
        [self finish];
        return;
    }
    NSMutableDictionary* mutableAttributes = [[NSMutableDictionary alloc] initWithDictionary:attributes];
    if (self.dataLog.globalId) {
        [mutableAttributes setValue:self.dataLog.globalId forKey:@"id"];
    }
    self.fetcher = [[WebServiceFetcher alloc] initWithCommand: command Entity:self.dataLog.entityTitle AndAttributes:mutableAttributes];
    self.status = SyncMobileStatusWaitingAttributesUpload;
    [self.fetcher makeRequestWithCallBack:^(NSDictionary *result, NSURLResponse *response, WebServiceFetcherStatus status, NSError *error) {
        switch (status) {
            case WebServiceFetcherFinished: {
                self.status = SyncMobileStatusWaitingSyncResponsePersistence;
                if (!result[@"id"] || !result[@"data_log_id"]) {
                    self.status = SyncMobileStatusFailedToPersistResponse;
                    [self finish];
                    return;
                }
                if ([self.dataLog.command isEqualToNumber:@(NetworkCommandCreate)]) {
                    self.dataLog.globalId = result[@"id"];
                    NSError* error;
                    NSManagedObject* obj = [self.context existingObjectWithID:self.dataLog.localId error:&error];
                    if (error) {
                        self.status = SyncMobileStatusFailedToPersistResponse;
                        [self finish];
                        return;
                    }
                    [obj setValue:result[@"id"] forKey:@"id"];
                }
                self.dataLog.id = result[@"data_log_id"];
                [self saveContext];
                [self handleSync];
            }
                break;
            default:{
                self.status = SyncMobileStatusFailedAttributesUpload;
                [self finish];
                return;
            }
                break;
        }
    }];
}

- (void) handleSync {
    self.fetcher = [[WebServiceFetcher alloc] initWithCommand:NetworkCommandUpdate Entity:@"DataLog" AndAttributes:@{@"id": self.dataLog.id, @"status": @(SyncMobileStatusSynced)}];
    self.status = SyncMobileStatusWaitingSyncUpload;
    [self.fetcher makeRequestWithCallBack:^(NSDictionary *result, NSURLResponse *response, WebServiceFetcherStatus status, NSError *error) {
        switch (status) {
            case WebServiceFetcherFinished:
                self.status = SyncMobileStatusSynced;
                break;
                
            default:
                self.status = SyncMobileStatusFailedSyncUpload;
                break;
        }
        [self finish];
    }];
}

#pragma mark private methods

- (void) saveContext {
    NSError* error;
    [self.context save:&error];
    if (error) {
        self.status = SyncMobileStatusFailedToSatisfyModelConstraints;
        self.dataLog.userInfo = [self dictionatyToString:error.userInfo];
        return;
    }
    [self.context.parentContext save:&error];
    if (error) {
        self.status = SyncMobileStatusFailedToSatisfyModelConstraints;
        self.dataLog.userInfo = [self dictionatyToString:error.userInfo];
        return;
    }
    
}

- (void) finish {
    [self saveContext];
}


- (NSString*) dictionatyToString: (NSDictionary*) dict {
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
@end
