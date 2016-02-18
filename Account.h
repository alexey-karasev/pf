//
//  Account.h
//  pf
//
//  Created by Алексей Карасев on 01/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
    debitAccount = 0,
    creditAccount = 1
} AccountCategory;

@class AccountGroup, Transaction, User;

NS_ASSUME_NONNULL_BEGIN

@interface Account : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "Account+CoreDataProperties.h"
