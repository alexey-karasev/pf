//
//  AccountGroup+CoreDataProperties.h
//  pf
//
//  Created by Алексей Карасев on 07/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "AccountGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface AccountGroup (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *id;
@property (nullable, nonatomic, retain) NSSet<Account *> *accounts;
@property (nullable, nonatomic, retain) User *user;

@end

@interface AccountGroup (CoreDataGeneratedAccessors)

- (void)addAccountsObject:(Account *)value;
- (void)removeAccountsObject:(Account *)value;
- (void)addAccounts:(NSSet<Account *> *)values;
- (void)removeAccounts:(NSSet<Account *> *)values;

@end

NS_ASSUME_NONNULL_END
