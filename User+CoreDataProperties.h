//
//  User+CoreDataProperties.h
//  pf
//
//  Created by Алексей Карасев on 07/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *nick;
@property (nullable, nonatomic, retain) NSString *id;
@property (nullable, nonatomic, retain) NSSet<AccountGroup *> *accountGroups;
@property (nullable, nonatomic, retain) NSSet<Account *> *accounts;
@property (nullable, nonatomic, retain) NSSet<Transaction *> *transactions;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addAccountGroupsObject:(AccountGroup *)value;
- (void)removeAccountGroupsObject:(AccountGroup *)value;
- (void)addAccountGroups:(NSSet<AccountGroup *> *)values;
- (void)removeAccountGroups:(NSSet<AccountGroup *> *)values;

- (void)addAccountsObject:(Account *)value;
- (void)removeAccountsObject:(Account *)value;
- (void)addAccounts:(NSSet<Account *> *)values;
- (void)removeAccounts:(NSSet<Account *> *)values;

- (void)addTransactionsObject:(Transaction *)value;
- (void)removeTransactionsObject:(Transaction *)value;
- (void)addTransactions:(NSSet<Transaction *> *)values;
- (void)removeTransactions:(NSSet<Transaction *> *)values;

@end

NS_ASSUME_NONNULL_END
