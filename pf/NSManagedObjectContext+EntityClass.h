//
//  NSManagedObjectContext+EntityClass.h
//  pf
//
//  Created by Алексей Карасев on 06/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MagicalRecord/MagicalRecord.h>

@interface NSManagedObjectContext (EntityClass)

- (NSEntityDescription*) PF_entityDescriptionWithName: (NSString*) entityName;
- (Class) PF_classWithEntityName: (NSString*) name;

@end
