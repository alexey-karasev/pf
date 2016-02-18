//
//  WebSyncJsonConverter.m
//  pf
//
//  Created by Алексей Карасев on 05/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import "WebCoreDataFacade.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Model.h"
#import "NSString+Camelize.h"
#import "ContextManager.h"

@implementation WebCoreDataFacade

+ (id)sharedInstance {
    static WebCoreDataFacade *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSManagedObjectContext*) context {
    if (!_context) {
        _context = [[ContextManager sharedInstance] mainContext] ;
    }
    return _context;
}

- (NSData*) dictionaryToJsonString: (NSDictionary*) dictionary {
    return [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:nil];
}


- (NSDictionary*) managedObjectToDictionary: (NSManagedObject*) obj {
    NSMutableDictionary* result = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSEntityDescription* entity = obj.entity;
    for (id property in entity.properties) {
        if ([property isKindOfClass:[NSAttributeDescription class]]) {
            NSAttributeDescription* attribute = (NSAttributeDescription*) property;
            id value = [obj valueForKey:attribute.name];
            if (value) {
                NSString* uncamelizedName = [attribute.name PF_unCamelizedString];
                result[uncamelizedName] = value;
            }
            
        } else if ([property isKindOfClass:[NSRelationshipDescription class]]) {
            NSRelationshipDescription* relationship = (NSRelationshipDescription*) property;
            if (!relationship.isToMany) {
                id value = [obj valueForKey:relationship.name];
                NSManagedObject* managedObj = (NSManagedObject*) value;
                id id = [managedObj valueForKey:@"id"];
                if (id) {
                    NSString* uncamelizedName = [relationship.name PF_unCamelizedString];
                    NSString* nameWithId = [@[uncamelizedName, @"_id"] componentsJoinedByString:@""];
                    result[nameWithId] = id;
                }
            }
        }
    }
    return result;
}
@end
