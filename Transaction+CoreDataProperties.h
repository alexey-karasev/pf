//
//  Transaction+CoreDataProperties.h
//  pf
//
//  Created by Алексей Карасев on 07/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Transaction.h"

NS_ASSUME_NONNULL_BEGIN

@interface Transaction (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *id;
@property (nullable, nonatomic, retain) NSNumber *value;
@property (nullable, nonatomic, retain) Account *creditAccount;
@property (nullable, nonatomic, retain) Account *debitAccount;
@property (nullable, nonatomic, retain) User *user;

@end

NS_ASSUME_NONNULL_END
