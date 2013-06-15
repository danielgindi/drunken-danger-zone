//
//  NSString+EmailValidation.m
//  Additions
//
//  Created by Daniel Cohen Gindi on 3/25/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "NSString+EmailValidation.h"

@implementation NSString (EmailValidation)

- (BOOL)isValidEmailAddress
{
    static NSRegularExpression * regex = nil;
    if (!regex)
    {
        regex = [[NSRegularExpression alloc] initWithPattern:@"^[a-zA-Z0-9\\._%+\\-]+@[a-zA-Z0-9\\-]+(\\.[a-zA-Z0-9\\-]+)*$" options:0 error:nil];
    }
    return nil != [regex firstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
}

@end
