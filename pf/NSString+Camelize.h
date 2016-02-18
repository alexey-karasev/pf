//
//  Camelize.h
//  pf
//
//  Created by Алексей Карасев on 05/11/15.
//  Copyright © 2015 Алексей Карасев. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (PF_Camelize)

- (NSString*) PF_unCamelizedString;
- (NSString*) PF_camelizedString;

@end
