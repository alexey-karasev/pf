//
//  ReachabilityService.h
//  pf
//
//  Created by Алексей Карасев on 09/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "Reachability.h"
#import "ReachabilityServiceSubscriber.h"

@interface ReachabilityService : NSObject <Singleton>

- (void) subscribe: (id<ReachabilityServiceSubscriber>) subscriber;
- (void) unSubscribe: (id<ReachabilityServiceSubscriber>) subscriber;

@end
