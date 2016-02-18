//
//  Account+CoreDataProperties.h
//  pf
//
//  Created by Алексей Карасев on 08/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Account.h"

NS_ASSUME_NONNULL_BEGIN

@interface Account (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *id;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *category;
@property (nullable, nonatomic, retain) NSNumber *visible;
@property (nullable, nonatomic, retain) AccountGroup *accountGroup;
@property (nullable, nonatomic, retain) NSSet<Transaction *> *creditTransactions;
@property (nullable, nonatomic, retain) NSSet<Transaction *> *debitTransactions;
@property (nullable, nonatomic, retain) User *user;

@end

@interface Account (CoreDataGeneratedAccessors)

- (void)addCreditTransactionsObject:(Transaction *)value;
- (void)removeCreditTransactionsObject:(Transaction *)value;
- (void)addCreditTransactions:(NSSet<Transaction *> *)values;
- (void)removeCreditTransactions:(NSSet<Transaction *> *)values;

- (void)addDebitTransactionsObject:(Transaction *)value;
- (void)removeDebitTransactionsObject:(Transaction *)value;
- (void)addDebitTransactions:(NSSet<Transaction *> *)values;
- (void)removeDebitTransactions:(NSSet<Transaction *> *)values;

@end

NS_ASSUME_NONNULL_END
