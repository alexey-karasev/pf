//
//  RequestFactorySpec.m
//  pf
//
//  Created by Алексей Карасев on 10/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import "Kiwi.h"
#import <MagicalRecord/MagicalRecord.h>
#import "TestModel.h"
#import "RequestFactory.h"
#import "Singleton.h"

SPEC_BEGIN(RequestFactorySpec)

describe (@"RequestFactory", ^{
    
    __block RequestFactory* factory;
    
    beforeEach(^{
        factory = [[RequestFactory alloc] init];
    });
    
    it (@"is a singleton", ^{
        [[[RequestFactory sharedInstance] should] beNonNil];
    });
    
    describe (@"createRequestForCommand:WithEntity:AndAttributes", ^{
        
        context (@"EntityName doesn't exist in NSManagedObjectContext", ^{
            it (@"proceeds as normal", ^{
                [factory createRequestForCommand:NetworkCommandCreate WithEntity:@"jfvfkkfjut" AndAttributes:@{}];
            });
        });
        
        context (@"entityName is nil", ^{
            it (@"creates a request to the root", ^{
                NSURLRequest* request = [factory createRequestForCommand:NetworkCommandCreate WithEntity:nil AndAttributes:@{}];
                [[request.URL.absoluteString should] equal:factory.host];
            });
        });
        
        context (@"attributes is nil", ^{
            it (@"doesn't set the body", ^{
                NSURLRequest* request = [factory createRequestForCommand:NetworkCommandCreate WithEntity:nil AndAttributes:nil];
                [[request.HTTPBody should] beNil];
            });
        });
        
        context (@"attributes are not a json object", ^{
            it (@"raises an error", ^{
                [[theBlock(^{
                    [factory createRequestForCommand:NetworkCommandCreate WithEntity:@"TestGroup" AndAttributes:@{@"name":[[NSObject alloc] init]}];
                }) should] raise];
            });
        });
        
        context(@"command == NetworkCommandCreate", ^{
            it (@"creates a post request with body", ^{
                
                NSURLRequest* request = [factory createRequestForCommand:NetworkCommandCreate WithEntity:@"TestGroup" AndAttributes:@{@"name":@"testname"}];
                [[request.URL.absoluteString should] equal:[@[factory.host, @"/test_groups"] componentsJoinedByString:@""]];
                [[request.HTTPMethod should] equal:@"POST"];
                NSString* bodyString = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
                NSString* bodyBenchmark = @"{\"name\":\"testname\"}";
                [[bodyBenchmark should] equal:bodyString];
            });
            
            context (@"command == NetworkCommandRead", ^{
                context (@"id provided in attributes", ^{
                    it (@"requests an entity with specific id, all attribites are dismissed", ^{
                        NSURLRequest* request = [factory createRequestForCommand:NetworkCommandRead WithEntity:@"TestGroup" AndAttributes:@{@"name":@"testname", @"id":@"1"}];
                        [[request.URL.absoluteString should] equal:[@[factory.host, @"/test_groups/1"] componentsJoinedByString:@""]];
                        [[request.HTTPMethod should] equal:@"GET"];
                        [[request.HTTPBody should] beNil];

                    });
                });
                
                context (@"id is not provided", ^{
                    it (@"requests all entities, attributes are translated to URL (for filtering)", ^{
                        NSURLRequest* request = [factory createRequestForCommand:NetworkCommandRead WithEntity:@"TestGroup" AndAttributes:@{@"name":@"test name"}];
                        [[request.URL.absoluteString should] equal:[@[factory.host, @"/test_groups?name=test%20name"] componentsJoinedByString:@""]];
                        [[request.HTTPMethod should] equal:@"GET"];
                        [[request.HTTPBody should] beNil];

                    });
                });

            });
            
            context (@"command == NetworkCommandUpdate", ^{
                it (@"creates a patch request to server", ^{
                    NSURLRequest* request = [factory createRequestForCommand:NetworkCommandUpdate WithEntity:@"TestGroup" AndAttributes:@{@"name":@"testname", @"id":@"1"}];
                    [[request.URL.absoluteString should] equal:[@[factory.host, @"/test_groups/1"] componentsJoinedByString:@""]];
                    [[request.HTTPMethod should] equal:@"PATCH"];;
                    NSDictionary* bodyDictionary = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:kNilOptions error:nil];
                    [[bodyDictionary.allKeys should] haveCountOf:1];
                    [[bodyDictionary[@"name"] should] equal:@"testname"];
                });
                
                context (@"No id supplied", ^{
                    it(@"raises InvalidArgumentsException", ^{
                        [[theBlock(^{
                            [factory createRequestForCommand:NetworkCommandUpdate WithEntity:@"TestGroup" AndAttributes:@{@"name":@"testname", @"mid":@"1"}];
                        }) should] raiseWithName:@"InvalidArgumentsException"];
                    });
                });
            });
            
            context (@"command == NetworkCommandDelete", ^{
                it (@"creates a delete request to server, attributes are dismissed", ^{
                    NSURLRequest* request = [factory createRequestForCommand:NetworkCommandDelete WithEntity:@"TestGroup" AndAttributes:@{@"name":@"testname", @"id":@"1"}];
                    [[request.URL.absoluteString should] equal:[@[factory.host, @"/test_groups/1"] componentsJoinedByString:@""]];
                    [[request.HTTPMethod should] equal:@"DELETE"];;
                    [[request.HTTPBody should] beNil];
                });
                
                context (@"No id supplied", ^{
                    it(@"raises InvalidArgumentsException", ^{
                        [[theBlock(^{
                            [factory createRequestForCommand:NetworkCommandDelete WithEntity:@"TestGroup" AndAttributes:@{@"name":@"testname", @"mid":@"1"}];
                        }) should] raiseWithName:@"InvalidArgumentsException"];
                    });
                });
            });
            

        });

    });
    
});

SPEC_END
