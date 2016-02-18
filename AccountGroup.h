//
//  AccountGroup.h
//  pf
//
//  Created by Алексей Карасев on 01/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account, User;

NS_ASSUME_NONNULL_BEGIN

@interface AccountGroup : NSManagedObject

+ (NSArray*) defaultNames;

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "AccountGroup+CoreDataProperties.h"
