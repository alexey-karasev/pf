//
//  CoreDataSeeder.h
//  pf
//
//  Created by Алексей Карасев on 01/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

@interface CoreDataSeeder : NSObject

@property (nonatomic, strong) NSManagedObjectContext *context;

- (instancetype) initWithContext: (NSManagedObjectContext*) context;

- (void) importEntity:(NSString*) entityName FromData: (NSData*) data;
- (void) importEntity:(NSString*) entityName FromResource: (NSString*) resourceName;
- (void) seed;

@end
