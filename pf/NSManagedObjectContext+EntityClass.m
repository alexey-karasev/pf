//
//  NSManagedObjectContext+EntityClass.m
//  pf
//
//  Created by Алексей Карасев on 06/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import "NSManagedObjectContext+EntityClass.h"

@implementation NSManagedObjectContext (EntityClass)

- (NSEntityDescription*) PF_entityDescriptionWithName: (NSString*) entityName {
    NSManagedObjectModel *managedObjectModel = [[self persistentStoreCoordinator] managedObjectModel];
    return [[managedObjectModel entitiesByName] objectForKey:entityName];
}

- (Class) PF_classWithEntityName: (NSString*) name {
    Class result = nil;
    NSEntityDescription* entityDescription = [self PF_entityDescriptionWithName:name];
    if (entityDescription) {
        result = NSClassFromString(name);
    }
    else {
        [NSException raise:@"EntityNotFound" format:@"The entity %@ not found in context %@", name, self];
    }
    return result;
}

@end
