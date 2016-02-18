//
//  SyncWebServiceFetcherSpec.m
//  pf
//
//  Created by Алексей Карасев on 08/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import "Kiwi.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Model.h"
#import "RequestFactory.h"
#import "WebServiceFetcher.h"
#import "Nocilla.h"

@interface WebServiceFetcher (UnitTest)
@property (nonatomic, strong, readwrite) NSArray<NSNumber*> *retrySchedule;
@property (nonatomic, readwrite) NSUInteger retryState;
@property (nonatomic, strong) NSURLRequest *request;
@end

@implementation WebServiceFetcher (UnitTest)

@dynamic retrySchedule;
@dynamic retryState;
@dynamic request;

        // make server reachable after 1st retry
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context   {
    if ([keyPath isEqualToString:@"retryState"]) {
        [[LSNocilla sharedInstance] clearStubs];
        stubRequest(@"POST", @"https://localhost:3000/users").
        withHeaders(@{@"content-type":@"application/json"}).
        withBody(@"{\"name\":\"foo\"}").
        andReturn(200).
        withHeaders(@{@"Content-Type": @"application/json"}).
        withBody(@"{\"id\":\"10\"}");
    }
}

@end

SPEC_BEGIN(WebServiceFetcherSpec)

describe (@"WebServiceFetcherSpec", ^{
    
    beforeEach(^{
        [[LSNocilla sharedInstance] start];
        [MagicalRecord cleanUp];
        [MagicalRecord setDefaultModelNamed:@"pf.momd"];
        [MagicalRecord setupCoreDataStackWithInMemoryStore];
    });
    
    afterEach(^{
        [MagicalRecord cleanUp];
        [[LSNocilla sharedInstance] stop];
        [[LSNocilla sharedInstance] clearStubs];
    });

    describe (@"initWithRequest", ^{
        it (@"inits with a request", ^{
            NSURLRequest* request = [[NSURLRequest alloc] init];
            WebServiceFetcher* fetcher = [[WebServiceFetcher alloc] initWithRequest:request];
            [[fetcher.request should] equal:request];
        });
    });
    
    describe (@"initWithCommand:Entity:AndAttributes", ^{
        it (@"it inits with a REST request according to RequestFactory", ^{
            NSURLRequest* request = [[RequestFactory sharedInstance] createRequestForCommand:NetworkCommandCreate WithEntity:@"AccountGroup" AndAttributes:@{@"name":@"testname"}];
            WebServiceFetcher* fetcher = [[WebServiceFetcher alloc] initWithCommand:NetworkCommandCreate Entity:@"AccountGroup" AndAttributes: @{@"name":@"testname"}];
            [[fetcher.request.URL.absoluteString should] equal:request.URL.absoluteString];
            [[fetcher.request.HTTPBody should] equal:request.HTTPBody];
        });
    });
    
    describe (@"makeRequestWithCallBack", ^{
        
        __block WebServiceFetcher* fetcher;
        
        void (^stubRequestWithBody)(NSString*) = ^void (NSString* body) {
            stubRequest(@"POST", @"https://localhost:3000/users").
            withHeaders(@{@"content-type":@"application/json"}).
            withBody(@"{\"name\":\"foo\"}").
            andReturn(200).
            withHeaders(@{@"Content-Type": @"application/json"}).
            withBody(body);
        };
        
        void (^stubRequestWithUnreachable)() = ^void () {
            stubRequest(@"POST", @"https://localhost:3000/users").
            withHeaders(@{@"content-type":@"application/json"}).
            withBody(@"{\"name\":\"foo\"}").
            andFailWithError([NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:nil]);
        };
        
        beforeEach(^{
            NSURL* url = [[NSURL alloc] initWithString:@"https://localhost:3000/users"];
            NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
            request.HTTPMethod = @"POST";
            [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
            request.HTTPBody = [@"{\"name\":\"foo\"}" dataUsingEncoding:NSUTF8StringEncoding];
            fetcher = [[WebServiceFetcher alloc] initWithRequest:request];

        });
        
        context (@"No problems with network and server", ^{
            it (@"sends the request and invokes specified callback", ^{
                stubRequestWithBody(@"{\"id\":\"2\"}");
                __block NSDictionary* fetchResult = nil;
                [fetcher makeRequestWithCallBack:^(NSDictionary *result, NSURLResponse *response, WebServiceFetcherStatus status, NSError *error) {
                    fetchResult = result;
                }];
                [[expectFutureValue(fetchResult) shouldEventually] equal:@{@"id":@"2"}];

            });
        });
        
        context (@"Server is unreachable", ^{
            
            beforeEach(^{
                stubRequestWithUnreachable();
            });
            
            it (@"makes retries according to retry schedule and sets the state to WebServiceFetcherServerIsUnreachable", ^{
                fetcher.retrySchedule = @[@0.01];
                [fetcher makeRequestWithCallBack:^(NSDictionary *result, NSURLResponse *response, WebServiceFetcherStatus status, NSError *error) {
                    int a = 1;
                }];
                [[expectFutureValue(@(fetcher.status)) shouldEventually] equal:@(WebServiceFetcherServerIsUnreachable)];
                [[expectFutureValue(@(fetcher.retryState)) shouldEventually] equal:@(1)];
            });
            
            it (@"makes several retries if specified by schedule", ^{
                fetcher.retrySchedule = @[@0.01, @0.01, @0.01];
                [fetcher makeRequestWithCallBack:^(NSDictionary *result, NSURLResponse *response, WebServiceFetcherStatus status, NSError *error) {
                }];
                [[expectFutureValue(theValue(fetcher.retryState)) shouldEventually] equal:theValue(3)];
            });
            
            it (@"proceeds as normal if the server becomes reachable", ^{

                fetcher.retrySchedule = @[@0.01];
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                [fetcher makeRequestWithCallBack:^(NSDictionary *result, NSURLResponse *response, WebServiceFetcherStatus status, NSError *error) {
                    dispatch_semaphore_signal(semaphore);
                }];
                [fetcher addObserver:fetcher forKeyPath:@"retryState" options:NSKeyValueObservingOptionNew context:nil];
                dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1*NSEC_PER_SEC)));
                [[@(fetcher.status) should] equal:@(WebServiceFetcherFinished)];
                [[@(fetcher.retryState) should] equal:@(1)];
            });
                
            
        });
    });
    
});

SPEC_END