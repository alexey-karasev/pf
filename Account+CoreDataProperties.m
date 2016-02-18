//
//  Account+CoreDataProperties.m
//  pf
//
//  Created by Алексей Карасев on 08/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Account+CoreDataProperties.h"

@implementation Account (CoreDataProperties)

@dynamic id;
@dynamic name;
@dynamic category;
@dynamic visible;
@dynamic accountGroup;
@dynamic creditTransactions;
@dynamic debitTransactions;
@dynamic user;

@end
