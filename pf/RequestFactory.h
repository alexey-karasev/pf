//
//  RequestFactory.h
//  pf
//
//  Created by Алексей Карасев on 10/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    NetworkCommandCreate = 0,
    NetworkCommandRead = 1,
    NetworkCommandUpdate = 2,
    NetworkCommandDelete = 3
} NetworkCommand;


@interface RequestFactory : NSObject

+ (id)sharedInstance;

@property (nonatomic, strong) NSString *host;

- (NSURLRequest*) createRequestForCommand: (NetworkCommand) command WithEntity: (NSString*) entityName AndAttributes: (NSDictionary*) attributes;

@end
