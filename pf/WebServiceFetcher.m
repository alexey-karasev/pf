//
//  SyncWebServiceFetcher.m
//  pf
//
//  Created by Алексей Карасев on 08/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import "WebServiceFetcher.h"


@interface WebServiceFetcher ()
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) WebServiceCallback callback;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic) NSUInteger retryState;
@property (nonatomic, strong) NSMutableArray<NSURLSessionTask*>* tasks;
@property (nonatomic, strong) NSArray<NSNumber*> *retrySchedule;
@end

@implementation WebServiceFetcher


#pragma mark initializers

- (instancetype) initWithRequest: (NSURLRequest*) request  {
    self = [super init];
    _request = request;
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration] delegate:self delegateQueue:nil];
    _retrySchedule = [WebServiceFetcher retryDelaysPattern];
    _retryState = 0;
    _tasks = [[NSMutableArray alloc] initWithCapacity:0];
    _status = WebServiceFetcherInitial;
    return self;
}

- (instancetype) initWithCommand:(NetworkCommand) command Entity: (NSString*) entity    AndAttributes: (NSDictionary*) attributes {
    NSURLRequest* request = [[RequestFactory sharedInstance] createRequestForCommand:command WithEntity:entity AndAttributes:attributes];
    self = [self initWithRequest:request];
    return self;
}

- (void) dealloc {
    [self.session invalidateAndCancel];
}

#pragma mark public api

- (void) makeRequestWithCallBack:(WebServiceCallback)callback {
    self.callback = callback;
    if (self.session && ([self.tasks count] == 0)) {
        NSURLSessionDataTask* task = [self.session dataTaskWithRequest:self.request];
        [self.tasks addObject:task];
        self.status = WebServiceFetcherWaitingResponse;
        [task resume];
    } else {
        self.status = WebServiceFetcherUnknownError;
        self.callback(nil, nil, self.status, nil);
    }
}

#pragma mark session delegate

- (void) URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (!self.responseData) {
        self.responseData = [[NSMutableData alloc] initWithData:data];
    } else {
        [self.responseData appendData:data];
    }
}

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        [self handleConnectionError:error ofTask:task];
    }
    else {
        self.status = WebServiceFetcherProcessingResponse;
        NSDictionary* result;
        if (self.responseData) {
            NSError* jsonError;
            result = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:&jsonError];
            if (jsonError) {
                NSLog(@"Session %@ reported json error: %@", task.originalRequest.URL, jsonError);
                self.error = jsonError;
                self.status = WebServiceFetcherInternalServerError;
            } else  {
                NSError* error = [[NSError alloc] initWithDomain:@"EmptyResponseError" code:0 userInfo:@{@"description": [[NSString alloc] initWithFormat:@"Url %@ returned empty response", task.originalRequest.URL.absoluteString]}];
                self.status = WebServiceFetcherInternalServerError;
            }self.status = WebServiceFetcherFinished;
        } else {result = @{};}
        self.callback(result, task.response, self.status, error);
    }
}


#pragma mark private methods

- (void) handleConnectionError: (NSError*) error ofTask: (NSURLSessionTask*) task {
    NSLog(@"Session %@ reported error: %@", task.originalRequest.URL, error);
    for (NSURLSessionTask* task in self.tasks) {
        [task cancel];
    }
    self.tasks = [[NSMutableArray alloc] initWithCapacity:0];
    NSTimeInterval retryDelay = [self timeForRetry:self.retryState];
    if (retryDelay) {
        [self dispatchAfterSeconds:retryDelay Block:^{
            self.retryState+=1;
            [self makeRequestWithCallBack: self.callback];
        }];
    }
    else {
        NSLog(@"Maximum number of retries reached - %lu", self.retryState);
        self.status = WebServiceFetcherServerIsUnreachable;
        self.error = error;
        self.callback(nil,nil,self.status, self.error);
    }
}

- (NSTimeInterval) timeForRetry: (NSUInteger) retry {
    if (retry >= [self.retrySchedule count]) {
        return 0;
    } else return [self.retrySchedule[retry] doubleValue];
}

- (void) dispatchAfterSeconds: (NSTimeInterval) seconds Block:(dispatch_block_t) block {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC));
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(popTime, queue, block);
}

+ (NSArray*) retryDelaysPattern {
    return @[@0.5, @1];
}


@end
