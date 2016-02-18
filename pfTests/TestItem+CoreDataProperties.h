//
//  TestItem+CoreDataProperties.h
//  pf
//
//  Created by Алексей Карасев on 07/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TestItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface TestItem (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *id;
@property (nullable, nonatomic, retain) TestGroup *testGroup;
@property (nullable, nonatomic, retain) TestParent *testParent;

@end

NS_ASSUME_NONNULL_END
