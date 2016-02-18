//
//  TestParent+CoreDataProperties.h
//  pf
//
//  Created by Алексей Карасев on 07/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TestParent.h"

NS_ASSUME_NONNULL_BEGIN

@interface TestParent (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *id;
@property (nullable, nonatomic, retain) NSString *testAttribute;
@property (nullable, nonatomic, retain) TestItem *newRelationship;
@property (nullable, nonatomic, retain) NSSet<TestGroup *> *testGroups;

@end

@interface TestParent (CoreDataGeneratedAccessors)

- (void)addTestGroupsObject:(TestGroup *)value;
- (void)removeTestGroupsObject:(TestGroup *)value;
- (void)addTestGroups:(NSSet<TestGroup *> *)values;
- (void)removeTestGroups:(NSSet<TestGroup *> *)values;

@end

NS_ASSUME_NONNULL_END
