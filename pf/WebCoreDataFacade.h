//
//  WebSyncJsonConverter.h
//  pf
//
//  Created by Алексей Карасев on 05/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Singleton.h"

@interface WebCoreDataFacade : NSObject <Singleton>

+ (instancetype) sharedInstance;

@property (nonatomic, strong) NSManagedObjectContext *context;

- (NSDictionary*) managedObjectToDictionary: (NSManagedObject*) obj;

// converts dictionary to string, no spaces and \n
- (NSData*) dictionaryToJsonString: (NSDictionary*) dictionary;

@end
