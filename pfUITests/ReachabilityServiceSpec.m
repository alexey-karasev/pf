//
//  ReachabilityServiceSpec.m
//  pf
//
//  Created by Алексей Карасев on 09/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import "Kiwi.h"
#import <MagicalRecord/MagicalRecord.h>
#import "TestModel.h"
#import "ReachabilityService.h"

@interface ReachabilityService(UnitTest)

@property (nonatomic, strong, readwrite) Reachability* reachability;
@property (nonatomic, strong, readwrite) NSMutableArray* subscribers;

@end

SPEC_BEGIN(ReachabilityServiceSpec)

describe (@"ReachabilityService", ^{
    
    __block ReachabilityService* service;
    
    
    beforeEach(^{
        service = [[ReachabilityService alloc] init];
    });

    
    it (@"is a singleton", ^{
        [[[ReachabilityService sharedInstance] should] beNonNil];
    });
    
    context (@"subscribe:", ^{
        it (@"subsribes an object to reachability changes and calls back a reachabilityStatusChanged method on each change", ^{
            id reachabilityMock = [ReachabilityService nullMock];
            [[reachabilityMock should] receive:@selector(startNotifier)];
            [service setReachability:reachabilityMock];
            id subscriberMock = [KWMock mockForProtocol:@protocol(ReachabilityServiceSubscriber)];
            [[subscriberMock should] receive:@selector(reachabilityStatusChanged:)];
            [service subscribe:subscriberMock];
            [[NSNotificationCenter defaultCenter] postNotificationName:kReachabilityChangedNotification object:nil];
        });
        
        it (@"doesn't add the same subscriber twice", ^{
            id reachabilityMock = [ReachabilityService nullMock];
            [service setReachability:reachabilityMock];
            id subscriberMock = [KWMock nullMockForProtocol:@protocol(ReachabilityServiceSubscriber)];
            [service subscribe:subscriberMock];
            [service subscribe:subscriberMock];
            [[service.subscribers should] haveCountOf:1];
        });
        
        it (@"raises InvalidSubscriberExcetption if the subscriber is nil", ^{
            [[theBlock(^{
                [service subscribe:nil];
            }) should] raiseWithName:@"InvalidSubscriberExcetption"];
        });
        
    });
    
    context (@"unsubscribe:", ^{
        it (@"unsubsribes currently subscribed item and stops Reachability if no subscribers left", ^{
            id reachabilityMock = [ReachabilityService nullMock];
            [[reachabilityMock should] receive:@selector(stopNotifier)];
            [service setReachability:reachabilityMock];
            id subscriberMock = [KWMock mockForProtocol:@protocol(ReachabilityServiceSubscriber)];
            [service subscribe:subscriberMock];
            [service unSubscribe:subscriberMock];
            [[NSNotificationCenter defaultCenter] postNotificationName:kReachabilityChangedNotification object:nil];
        });
    });
    
});

SPEC_END
