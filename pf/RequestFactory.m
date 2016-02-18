//
//  RequestFactory.m
//  pf
//
//  Created by Алексей Карасев on 10/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import "RequestFactory.h"
#import "NSString+Camelize.h"

@implementation RequestFactory

+ (id)sharedInstance {
    static RequestFactory *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSString*) host {
    if (!_host) _host = @"http://localhost:3000";
    return _host;
}

- (NSURLRequest*) createRequestForCommand: (NetworkCommand) command WithEntity: (NSString*) entityName AndAttributes: (NSDictionary*) attributes {
#warning add custom sync headers
    NSMutableURLRequest* request;
    switch (command) {
        case NetworkCommandCreate: {
            NSString* urlString = entityName ? [@[self.host, @"/", [entityName PF_unCamelizedString], @"s"] componentsJoinedByString:@""] : self.host;
            NSURL* url = [[NSURL alloc] initWithString:urlString];
            request = [[NSMutableURLRequest alloc] initWithURL:url];
            request.HTTPMethod = @"POST";
            request.HTTPBody = [self attributesToData:attributes];
        }
            break;
        case NetworkCommandRead: {
            NSMutableArray* urlArray = [[NSMutableArray alloc] initWithArray:@[self.host, @"/", [entityName PF_unCamelizedString], @"s"]];
            NSString* ID = attributes[@"id"];
            if (ID) {
                [urlArray addObjectsFromArray:@[@"/",ID]];
            } else if (attributes) {
                NSMutableString* parameters = [[NSMutableString alloc] initWithCapacity:0];
                [attributes enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    [parameters appendString:[NSString stringWithFormat:@"%@=%@&", key, obj]];
                }];
                [parameters deleteCharactersInRange:NSMakeRange([parameters length]-1, 1)];
                NSString *escapedString = [parameters stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
                [urlArray addObjectsFromArray:@[@"?", escapedString]];
            }
            
            NSString* urlString = entityName ? [urlArray componentsJoinedByString:@""] : self.host;
            NSURL* url = [[NSURL alloc] initWithString:urlString];
            request = [[NSMutableURLRequest alloc] initWithURL:url];
            request.HTTPMethod = @"GET";
        }
            break;
            
        case NetworkCommandUpdate: {
            NSString* id = attributes[@"id"];
            if (!id) {
                [NSException raise:@"InvalidArgumentsException" format:@"id for the object was not specified in attributes"];
            }
            NSString* urlString = entityName ? [@[self.host, @"/", [entityName PF_unCamelizedString], @"s/", id] componentsJoinedByString:@""] : self.host;
            NSURL* url = [[NSURL alloc] initWithString:urlString];
            request = [[NSMutableURLRequest alloc] initWithURL:url];
            request.HTTPMethod = @"PATCH";
            NSMutableDictionary* modifiedAttributes = [[NSMutableDictionary alloc] initWithDictionary:attributes];
            [modifiedAttributes removeObjectForKey:@"id"];
            request.HTTPBody = [self attributesToData:modifiedAttributes];
        }
            break;
        case NetworkCommandDelete: {
            NSString* id = attributes[@"id"];
            if (!id) {
                [NSException raise:@"InvalidArgumentsException" format:@"id for the object was not specified in attributes"];
            }
            NSString* urlString = entityName ? [@[self.host, @"/", [entityName PF_unCamelizedString], @"s/", id] componentsJoinedByString:@""] : self.host;
            NSURL* url = [[NSURL alloc] initWithString:urlString];
            request = [[NSMutableURLRequest alloc] initWithURL:url];
            request.HTTPMethod = @"DELETE";
        }
            break;
        default:
            break;
    }
    if (request) {
        [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"accept"];
    }
    return request;
}

- (NSData*) attributesToData: (NSDictionary*) attributes {
    NSData* data;
    if (attributes) {
        NSError* error;
        data = [NSJSONSerialization dataWithJSONObject:attributes options:kNilOptions error:&error];
        if (error) {
            [NSException raise:@"NSInvalidJSONFormat" format:@"The attributes %@ raised error %@", attributes, error];
        }
    }
    return data;
}

@end
