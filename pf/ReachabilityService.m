//
//  ReachabilityService.m
//  pf
//
//  Created by Алексей Карасев on 09/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import "ReachabilityService.h"

@interface ReachabilityService ()

@property (nonatomic, strong) NSMutableArray<id<ReachabilityServiceSubscriber>> *subscribers;
@property (nonatomic, strong) Reachability* reachability;

@end

@implementation ReachabilityService

+ (id)sharedInstance {
    static ReachabilityService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype) init {
    self = [super init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notify) name:kReachabilityChangedNotification object:nil];
    return self;
}

- (NSMutableArray*) subscribers {
    if (!_subscribers) _subscribers = [[NSMutableArray alloc] initWithCapacity:0];
    return _subscribers;
}

- (Reachability*) reachability {
    if (!_reachability) _reachability = [Reachability reachabilityWithHostName:@"www.apple.com"];
    return _reachability;
}



- (void) subscribe: (id<ReachabilityServiceSubscriber>) subscriber{
    if (!subscriber) {
        [NSException raise:@"InvalidSubscriberExcetption" format:@"The subscriber cannot be nil"];
    }
    if ([self.subscribers indexOfObject:subscriber] == NSNotFound) {
        if ([self.subscribers count] == 0) {
            [self.reachability startNotifier];
        }
        [self.subscribers addObject:subscriber];
    }
}

- (void) unSubscribe:(id<ReachabilityServiceSubscriber>)subscriber {
    NSUInteger index = [self.subscribers indexOfObject:subscriber];
    if (index!=NSNotFound) {
        [self.subscribers removeObjectAtIndex:index];
    }
    if ([self.subscribers count] == 0) {
        [self.reachability stopNotifier];
    }
}

- (void) notify {
    for (int i=0; i<[self.subscribers count]; i++) {
        id<ReachabilityServiceSubscriber> subscriber = [self.subscribers objectAtIndex:i];
        [subscriber reachabilityStatusChanged:self.reachability.currentReachabilityStatus];
    }
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
