//
//  CoreDataSeeder.m
//  pf
//
//  Created by Алексей Карасев on 01/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import "CoreDataSeeder.h"
#import <MagicalRecord/MagicalRecord.h>
#import "NSManagedObjectContext+EntityClass.h"
#import "ContextManager.h"

@interface CoreDataSeeder()

@end

@implementation CoreDataSeeder


- (instancetype) initWithContext: (NSManagedObjectContext*) context {
    self = [super init];
    _context = context;
    return self;
}

- (NSManagedObjectContext*) context {
    if (!_context) {
        _context = [[ContextManager sharedInstance] mainContext];
    }
    return _context;
}

- (void) importEntity:(NSString*) entityName FromData: (NSData*) data {
    NSError * error=nil;
    if (!data) return;
    id parsedData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error) {
        [NSException raise:@"InvalidJSONFormat" format:@"Invalid JSON format for entity %@", entityName ];
    }
        if ([parsedData isKindOfClass:[NSArray class]]) {
            [[self.context PF_classWithEntityName:entityName] MR_importFromArray:parsedData inContext:self.context];
        } else {
            [[self.context PF_classWithEntityName:entityName] MR_importFromObject:parsedData inContext:self.context];
        }
}

- (void) importEntity:(NSString*) entityName FromResource: (NSString*) resourceName {
    NSString* path = [[NSBundle mainBundle] pathForResource:resourceName ofType:@"yml"];
    NSError* error = nil;
    NSData* data = [NSData dataWithContentsOfFile:path options:NSDataReadingUncached error:&error];
    if (error) {
        [NSException raise:@"IncorrectSeedFormat" format:@"Resource %@ has the following errors: %@", resourceName, error.userInfo];
    }
    [self importEntity:entityName FromData:data];
}

- (void) seed {
    [self importEntity:@"User" FromResource:@"Users"];
    [self importEntity:@"AccountGroup" FromResource:@"AccountGroups"];
    [self importEntity:@"Account" FromResource:@"Accounts"];
    [self importEntity:@"Transaction" FromResource:@"Transactions"];
}


@end
