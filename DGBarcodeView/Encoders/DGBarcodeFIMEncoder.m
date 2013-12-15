//
//  DGBarcodeFIMEncoder.m
//  DGBarcodeView
//
//  Created by Daniel Cohen Gindi on 1/31/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGBarcodeFIMEncoder.h"

@implementation DGBarcodeFIMEncoder

- (NSString *)encodedValueWithValue:(NSString *)value
{
    static NSString *FIM_Codes[] = { @"110010011", @"101101101", @"110101011", @"111010111" };
    
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([value isEqualToString:@"A"] || [value isEqualToString:@"a"])
    {
        value = FIM_Codes[0];
    }
    else if ([value isEqualToString:@"B"] || [value isEqualToString:@"b"])
    {
        value = FIM_Codes[1];
    }
    else if ([value isEqualToString:@"C"] || [value isEqualToString:@"c"])
    {
        value = FIM_Codes[2];
    }
    else if ([value isEqualToString:@"D"] || [value isEqualToString:@"d"])
    {
        value = FIM_Codes[3];
    }
    else
    {
#if (DEBUG)
        NSLog(@"DGBarcodeEncoder FIM: Must be A, B, C or D");
#endif
        return nil;
    }
    
    NSMutableString *result = [[NSMutableString alloc] init];
    for (int j=0; j<value.length; j++)
    {
        [result appendString:[value substringWithRange:NSMakeRange(j, 1)]];
        [result appendString:@"0"];
    }
    [result deleteCharactersInRange:NSMakeRange(result.length-1, 1)];
    
    return [result copy];
}

@end