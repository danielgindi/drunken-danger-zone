//
//  DGBarcodeUPCSupplement2Encoder.m
//  DGBarcodeView
//
//  Created by Daniel Cohen Gindi on 1/31/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGBarcodeUPCSupplement2Encoder.h"

@implementation DGBarcodeUPCSupplement2Encoder

- (NSString *)encodedValueWithValue:(NSString *)value
{
    static NSString *EAN_CodeA[] = { @"0001101", @"0011001", @"0010011", @"0111101", @"0100011", @"0110001", @"0101111", @"0111011", @"0110111", @"0001011" };
    static NSString *EAN_CodeB[] = { @"0100111", @"0110011", @"0011011", @"0100001", @"0011101", @"0111001", @"0000101", @"0010001", @"0001001", @"0010111" };
    static NSString *UPC_SUPP_2[] = { @"aa", @"ab", @"ba", @"bb" };
    
    if (value.length != 2 || ![self isNumeric:value])
    {
#if (DEBUG)
        NSLog(@"DGBarcodeEncoder UPCA: Must be 2 digits");
#endif
        return nil;
    }
    
    NSString *pattern = UPC_SUPP_2[[value intValue] % 4];
    
    NSMutableString *result = [[NSMutableString alloc] initWithString:@"1011"];
    
    unichar c;
    for (int j=0; j<pattern.length; j++)
    {
        c = [pattern characterAtIndex:j];
        if (c == L'a')
        {
            [result appendString:EAN_CodeA[[value characterAtIndex:j] - L'0']];
        }
        else if (c == L'b')
        {
            [result appendString:EAN_CodeB[[value characterAtIndex:j] - L'0']];
        }
        
        if (j)
        {
            [result appendString:@"01"];
        }
    }
    
    return [result copy];
}

@end
