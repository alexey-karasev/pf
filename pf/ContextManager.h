//
//  ContextManager.h
//  pf
//
//  Created by Алексей Карасев on 06/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Singleton.h"

@interface ContextManager : NSObject <Singleton>

+ (id)sharedInstance;

@property (nonatomic, strong, readonly) NSManagedObjectContext *mainContext;
@property (nonatomic, strong, readonly) NSManagedObjectContext *rootMainContext;
@property (nonatomic, strong, readonly) NSManagedObjectContext *rootSyncContext;

- (NSManagedObjectContext*) createSyncContext;
- (void) resetRootSyncContext;

@end
