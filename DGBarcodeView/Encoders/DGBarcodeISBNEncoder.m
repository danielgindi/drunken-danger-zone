//
//  DGBarcodeISBNEncoder.m
//  DGBarcodeView
//
//  Created by Daniel Cohen Gindi on 1/31/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGBarcodeISBNEncoder.h"

@implementation DGBarcodeISBNEncoder

- (NSString *)encodedValueWithValue:(NSString *)value
{
    if (![self isNumeric:value])
    {
#if (DEBUG)
        NSLog(@"DGBarcodeEncoder ISBN: May contain digits only");
#endif
        return nil;
    }
    
    NSString *type = @"UNKNOWN";
    if (value.length == 10 || value.length == 9)
    {
        if (value.length == 10)
        {
            value = [value stringByReplacingCharactersInRange:NSMakeRange(9, 1) withString:@""];
        }
        value = [@"978" stringByAppendingString:value];
        type = @"ISBN";
    }
    else if (value.length == 12 && [value hasPrefix:@"978"])
    {
        type = @"BOOKLAND-NOCHECKDIGIT";
    }
    else if (value.length == 13 && [value hasPrefix:@"978"])
    {
        type = @"BOOKLAND-CHECKDIGIT";
        value = [value stringByReplacingCharactersInRange:NSMakeRange(12, 1) withString:@""];
    }
    
    if ([type isEqualToString:@"UNKNOWN"])
    {
#if (DEBUG)
        NSLog(@"DGBarcodeEncoder Standard2of5: Unknown type");
#endif
        return nil;
    }
    
    return [super encodedValueWithValue:value];
}

@end
