//
//  SyncMobileInsertHandler.h
//  pf
//
//  Created by Алексей Карасев on 08/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncHandler.h"

typedef enum : NSInteger {
    SyncMobileStatusInitial = 0,
    SyncMobileStatusWaitingAttributesUpload = 100,
    SyncMobileStatusWaitingAttributesResponsePersistence = 200,
    SyncMobileStatusWaitingSyncUpload = 300,
    SyncMobileStatusWaitingSyncResponsePersistence = 400,
    SyncMobileStatusSynced = 1000,
    SyncMobileStatusFailedAttributesUpload = -1000,
    SyncMobileStatusFailedSyncUpload = -2000,
    SyncMobileStatusInvalidAttributes = -3000,
    SyncMobileStatusFailedToSatisfyModelConstraints = -4000,
    SyncMobileStatusFailedToPersistResponse = -5000
} SyncMobileStatus;

@interface SyncMobileHandler : NSObject <SyncHandler>

@property (nonatomic, readonly) SyncMobileStatus status;

- (instancetype) initWithDataLogId: (NSManagedObjectID*) dataLogId;
- (void) handle;

@end
