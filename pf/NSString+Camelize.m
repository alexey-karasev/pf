//
//  Camelize.m
//  pf
//
//  Created by Алексей Карасев on 05/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import "NSString+Camelize.h"

@implementation NSString (PF_Camelize)

- (NSString*) PF_unCamelizedString {
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"^[A-Za-z0-9]*$" options:kNilOptions error:nil];
    if ([regex numberOfMatchesInString:self options:kNilOptions range:NSMakeRange(0, [self length])] == 0) {
        [NSException raise:@"InvalidCamelizeFormat" format:@"The string %@ is not in a dash format", self];
    }

    NSMutableString* result = [NSMutableString stringWithString:@""];
    for (int i=0; i < [self length]; i++) {
        NSString* currentChar = [self substringWithRange:NSMakeRange(i, 1)];
        if ([[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[currentChar characterAtIndex:0]]) {
            if ([result length]) // if the string starts with capital letter don't add dash
            [result insertString:@"_" atIndex:[result length]];
        }
        [result insertString:currentChar atIndex:[result length]];
    }
    return [result lowercaseString];
}

- (NSString*) PF_camelizedString {
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"^[a-z0-9]+(_[a-z0-9]+)*$" options:kNilOptions error:nil];
    if ([regex numberOfMatchesInString:self options:kNilOptions range:NSMakeRange(0, [self length])] == 0) {
        [NSException raise:@"InvalidCamelizeFormat" format:@"The string %@ is not in a dash format", self];
    }
    NSMutableString* result = [NSMutableString stringWithString:@""];
    BOOL capitalize = false;
    for (int i=0; i < [self length]; i++) {
        NSString* currentChar = [self substringWithRange:NSMakeRange(i, 1)];
        if (capitalize) {
            currentChar = [currentChar uppercaseString];
        }
        capitalize = false;
        if ([currentChar isEqualToString:@"_"]) {
            capitalize = true;
            continue;
        }
        [result insertString:currentChar atIndex:[result length]];
    }
    return result;
}

@end
