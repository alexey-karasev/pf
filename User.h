//
//  User.h
//  pf
//
//  Created by Алексей Карасев on 01/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Account.h"
#import "AccountGroup.h"
#import "Transaction.h"

@class Account, AccountGroup, Transaction;

NS_ASSUME_NONNULL_BEGIN

@interface User : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "User+CoreDataProperties.h"
