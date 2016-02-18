//
//  DataLog.h
//  pf
//
//  Created by Алексей Карасев on 10/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RequestFactory.h"

typedef enum : NSInteger {
    DataLogStatusAwaitingAttributesSync = 0,
    DataLogStatusStartedAttributesSync = 100,
    DataLogStatusServerConfirmedAttributesUpload = 200,
    DataLogStatusProcessedServerResponseForAttributes = 250,
    DataLogStatusAddedGlobalId = 300,
    DataLogStatusStartingSyncStatusSync = 400,
    DataLogStatusServerConfirmedSyncStatusUpload = 600,
    DataLogStatusProcessedServerResponseForSync = 700,
    DataLogStatusSynced = 1000,
    DataLogStatusFailedToStartAttributesSync = -1000,
    DataLogStatusFailedToUploadAttributesToServer = -1100,
    DataLogStatusFailedToReceiveGlobalId = -1200,
    DataLogStatusFailedToUploadSyncStatus = -1300
} DataLogStatus;

typedef enum : NSInteger {
    DataLogOriginMobile = 0,
    DataLogOriginWeb = 100
} DataLogOrigin;


NS_ASSUME_NONNULL_BEGIN

@interface DataLog : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "DataLog+CoreDataProperties.h"
