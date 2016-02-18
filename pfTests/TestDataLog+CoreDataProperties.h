//
//  TestDataLog+CoreDataProperties.h
//  pf
//
//  Created by Алексей Карасев on 10/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TestDataLog.h"

NS_ASSUME_NONNULL_BEGIN

@interface TestDataLog (CoreDataProperties)

@property (nullable, nonatomic, retain) id localId;
@property (nullable, nonatomic, retain) NSNumber *globalId;
@property (nullable, nonatomic, retain) NSString *attributes;
@property (nullable, nonatomic, retain) NSNumber *command;
@property (nullable, nonatomic, retain) NSString *entityTitle;
@property (nullable, nonatomic, retain) NSNumber *origin;
@property (nullable, nonatomic, retain) NSNumber *status;
@property (nullable, nonatomic, retain) NSString *userInfo;

@end

NS_ASSUME_NONNULL_END
