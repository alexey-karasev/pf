//
//  ManagedObjectIdTransformer.m
//  pf
//
//  Created by Алексей Карасев on 10/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import "ManagedObjectIdTransformer.h"
#import "Model.h"

@implementation ManagedObjectIdTransformer
+ (Class) transformedValueClass {
    return [NSData class];
}

+ (BOOL) allowsReverseTransformation {
    return YES;
}

- (id) transformedValue:(id)value {
    NSData* result;
    if (!value) return nil;
    if ([value isKindOfClass:[NSManagedObjectID class]]) {
        NSManagedObjectID* idValue = (NSManagedObjectID*) value;
        if ([value isTemporaryID]) {
            [NSException raise:@"InvalidAttributeValue" format:@"Expected permanent managedObjectId, but received temporary"];
        }
        NSURL* uri = [idValue URIRepresentation];
        result = [NSKeyedArchiver archivedDataWithRootObject:uri];
    } else {
        [NSException raise:@"InvalidAttributeValue" format:@"Expected NSManagedObjectId, but received: %@", [value class]];
    }
    return result;
}

- (id) reverseTransformedValue:(id)value {
    if (!value) return nil;
    NSManagedObjectID *objectID;
    if ([value isKindOfClass:[NSData class]]) {
        NSData* dataValue = (NSData*) value;
        NSURL* uri = [NSKeyedUnarchiver unarchiveObjectWithData:dataValue];
        NSManagedObjectContext* context = [NSManagedObjectContext MR_defaultContext];
        objectID =
        [[context persistentStoreCoordinator]
         managedObjectIDForURIRepresentation:uri];
    }
    else {
        [NSException raise:@"InvalidAttributeValue" format:@"Expected NSManagedObjectId, but received: %@", [value class]];
    }
    return objectID;
}

@end
