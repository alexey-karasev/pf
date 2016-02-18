//
//  ReachabilityServiceSubscriber.h
//  pf
//
//  Created by Алексей Карасев on 09/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@protocol ReachabilityServiceSubscriber <NSObject>

- (void) reachabilityStatusChanged:(NetworkStatus) status;

@end
