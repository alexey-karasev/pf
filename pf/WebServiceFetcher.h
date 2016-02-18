//
//  SyncWebServiceFetcher.h
//  pf
//
//  Created by Алексей Карасев on 08/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "ReachabilityServiceSubscriber.h"
#import "RequestFactory.h"

typedef enum : NSInteger {
    WebServiceFetcherInitial = 0,
    WebServiceFetcherWaitingResponse = 100,
    WebServiceFetcherProcessingResponse = 300,
    WebServiceFetcherFinished = 1000,
    WebServiceFetcherServerIsUnreachable = -3000,
    WebServiceFetcherInternalServerError = -4000,
    WebServiceFetcherUnknownError = -10000
} WebServiceFetcherStatus;

typedef void (^WebServiceCallback)(NSDictionary* result, NSURLResponse* response, WebServiceFetcherStatus status, NSError* error);

@interface WebServiceFetcher : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>


@property (nonatomic) WebServiceFetcherStatus status;
@property (nonatomic, strong) NSError *error;

- (instancetype) initWithRequest: (NSURLRequest*) request;
- (instancetype) initWithCommand:(NetworkCommand) command Entity: (NSString*) entity AndAttributes: (NSDictionary*) attributes;
- (void) makeRequestWithCallBack: (WebServiceCallback) callback;

@end
