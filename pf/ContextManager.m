//
//  ContextManager.m
//  pf
//
//  Created by Алексей Карасев on 06/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import "ContextManager.h"
#import <MagicalRecord/MagicalRecord.h>

@interface ContextManager ()
@property (nonatomic, strong, readwrite) NSManagedObjectContext *rootSyncContext;
@end


@implementation ContextManager

+ (id)sharedInstance {
    static ContextManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSManagedObjectContext*) mainContext {
    return [NSManagedObjectContext MR_defaultContext];
}

- (NSManagedObjectContext*) rootMainContext {
    return [NSManagedObjectContext MR_rootSavingContext];
}

- (NSManagedObjectContext*) rootSyncContext {
    if (!_rootSyncContext) {
        NSPersistentStoreCoordinator* coordinator = self.rootMainContext.persistentStoreCoordinator;
        _rootSyncContext = [NSManagedObjectContext MR_contextWithStoreCoordinator:coordinator];
    }
    return _rootSyncContext;
}

- (NSManagedObjectContext*) createSyncContext {
    NSManagedObjectContext* context = [NSManagedObjectContext MR_contextWithParent:self.rootSyncContext];
    return context;
}

- (void) resetRootSyncContext {
    _rootSyncContext = nil;
}

@end
