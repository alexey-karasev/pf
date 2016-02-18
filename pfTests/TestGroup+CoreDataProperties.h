//
//  TestGroup+CoreDataProperties.h
//  pf
//
//  Created by Алексей Карасев on 07/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TestGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface TestGroup (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *id;
@property (nullable, nonatomic, retain) NSString *longNameAttribute;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<TestItem *> *testItems;
@property (nullable, nonatomic, retain) TestParent *testParent;

@end

@interface TestGroup (CoreDataGeneratedAccessors)

- (void)addTestItemsObject:(TestItem *)value;
- (void)removeTestItemsObject:(TestItem *)value;
- (void)addTestItems:(NSSet<TestItem *> *)values;
- (void)removeTestItems:(NSSet<TestItem *> *)values;

@end

NS_ASSUME_NONNULL_END
