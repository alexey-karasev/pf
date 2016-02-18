//
//  DataLog+CoreDataProperties.h
//  pf
//
//  Created by Алексей Карасев on 12/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DataLog.h"

NS_ASSUME_NONNULL_BEGIN

@interface DataLog (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *status;
@property (nullable, nonatomic, retain) NSString *globalId;
@property (nullable, nonatomic, retain) NSString *entityTitle;
@property (nullable, nonatomic, retain) NSNumber *command;
@property (nullable, nonatomic, retain) NSString *attributes;
@property (nullable, nonatomic, retain) id localId;
@property (nullable, nonatomic, retain) NSString *userInfo;
@property (nullable, nonatomic, retain) NSNumber *origin;
@property (nullable, nonatomic, retain) NSString *id;

@end

NS_ASSUME_NONNULL_END
