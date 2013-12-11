//
//  DGBarcodeEAN8Encoder.m
//  DGBarcodeView
//
//  Created by Daniel Cohen Gindi on 1/31/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGBarcodeEAN8Encoder.h"

@implementation DGBarcodeEAN8Encoder

- (NSString *)encodedValueWithValue:(NSString *)value
{
    static NSString *EAN_CodeA[] = { @"0001101", @"0011001", @"0010011", @"0111101", @"0100011", @"0110001", @"0101111", @"0111011", @"0110111", @"0001011" };
    static NSString *EAN_CodeC[] = { @"1110010", @"1100110", @"1101100", @"1000010", @"1011100", @"1001110", @"1010000", @"1000100", @"1001000", @"1110100" };
    
    value = [self valueWithCheckDigitOfValue:value];
    
    if ((value.length != 8 && value.length != 7) || ![self isNumeric:value])
    {
#if (DEBUG)
        NSLog(@"DGBarcodeEncoder EAN8: Must be 7 or 8 digits");
#endif
        return nil;
    }
    
    NSMutableString *result = [[NSMutableString alloc] initWithString:@"101"];
    
    unichar *buffer = malloc(sizeof(unichar) * (value.length + 1));
    [value getCharacters:buffer];
    
    for (int i = 0; i < value.length / 2; i++)
    {
        [result appendString:EAN_CodeA[((int)(buffer[i] - L'0'))]];
    }

    [result appendString:@"01010"];
    
    for (int i = value.length / 2; i < value.length; i++)
    {
        [result appendString:EAN_CodeC[((int)(buffer[i] - L'0'))]];
    }
    
    [result appendString:@"101"];
    
    free(buffer);
    
    return [result copy];
}

- (NSString *)valueWithCheckDigitOfValue:(NSString *)value
{
    if (value.length == 7)
    {
        unichar *buffer = malloc(sizeof(unichar) * (value.length + 1));
        [value getCharacters:buffer];
        
        int even = 0;
        int odd = 0;
        
        for (int i = 0; i <= 6; i += 2)
        {
            odd += ((int)(buffer[i] - L'0')) * 3;
        }
        
        for (int i = 1; i <= 5; i += 2)
        {
            even += ((int)(buffer[i] - L'0'));
        }
        
        int total = even + odd;
        int cs = total % 10;
        cs = 10 - cs;
        if (cs == 10)
        {
            cs = 0;
        }
        
        free(buffer);
        
        return [value stringByAppendingString:[@(cs) stringValue]];
    }
    return value;
}

@end
