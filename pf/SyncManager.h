//
//  SyncManager.h
//  pf
//
//  Created by Алексей Карасев on 08/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol SyncManager <NSObject>

- (instancetype) initWithContext: (NSManagedObjectContext*) context;
- (void) sync;

@end
