//
//  DGBarcodeEAN13Encoder.m
//  DGBarcodeView
//
//  Created by Daniel Cohen Gindi on 1/31/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGBarcodeEAN13Encoder.h"

@implementation DGBarcodeEAN13Encoder

- (NSString *)encodedValueWithValue:(NSString *)value
{
    return [self encodedValueWithValue:value country:nil];
}

- (NSString *)encodedValueWithValue:(NSString *)value country:(out NSString **)country
{
    static NSString *EAN_CodeA[] = { @"0001101", @"0011001", @"0010011", @"0111101", @"0100011", @"0110001", @"0101111", @"0111011", @"0110111", @"0001011" };
    static NSString *EAN_CodeB[] = { @"0100111", @"0110011", @"0011011", @"0100001", @"0011101", @"0111001", @"0000101", @"0010001", @"0001001", @"0010111" };
    static NSString *EAN_CodeC[] = { @"1110010", @"1100110", @"1101100", @"1000010", @"1011100", @"1001110", @"1010000", @"1000100", @"1001000", @"1110100" };
    static NSString *EAN_Pattern[] = { @"aaaaaa", @"aababb", @"aabbab", @"aabbba", @"abaabb", @"abbaab", @"abbbaa", @"ababab", @"ababba", @"abbaba" };
    
    if (value.length < 12 || value.length > 13 || ![self isNumeric:value])
    {
#if (DEBUG)
        NSLog(@"DGBarcodeEncoder EAN13: Must be 12 or 13 digits");
#endif
        return nil;
    }
	
    value = [self valueWithCheckDigitOfValue:value];
    
    unichar *buffer = malloc(sizeof(unichar) * (value.length + 1));
    [value getCharacters:buffer];
    
    NSString *patterncode = EAN_Pattern[((int)(buffer[0] - L'0'))];
    NSMutableString *result = [[NSMutableString alloc] initWithString:@"101"];

    for (int pos = 0; pos < 6; pos++)
    {
        if ([patterncode characterAtIndex:pos] == 'a')
        {
            [result appendString:EAN_CodeA[((int)(buffer[pos + 1] - L'0'))]];
        }
        else if ([patterncode characterAtIndex:pos] == 'b')
        {
            [result appendString:EAN_CodeB[((int)(buffer[pos + 1] - L'0'))]];
        }
    }
    
    [result appendString:@"01010"];
    
    for (int pos = 1; pos <+ 5; pos++)
    {
        [result appendString:EAN_CodeC[((int)(buffer[pos + 6] - L'0'))]];
    }
    
    int cs = ((int)(buffer[value.length - 1] - L'0'));
    [result appendString:EAN_CodeC[cs]];
    [result appendString:@"101"];
    
    if (country)
    {
        *country = self.countryCodesMap[[value stringByAppendingString:[value substringToIndex:3]]];
        if (!*country)
        {
            *country = self.countryCodesMap[[value stringByAppendingString:[value substringToIndex:2]]];
        }
    }
    
    free(buffer);
    
    return [result copy];
}

- (NSString *)valueWithCheckDigitOfValue:(NSString *)value
{
    value = [value substringToIndex:12];
    unichar *buffer = malloc(sizeof(unichar) * (value.length + 1));
    [value getCharacters:buffer];
    
    int even = 0;
    int odd = 0;
    
    for (int i = 0; i < value.length; i++)
    {
        if (i % 2 == 0)
        {
            odd += ((int)(buffer[i] - L'0'));
        }
        else
        {
            even += ((int)(buffer[i] - L'0')) * 3;
        }
    }
    
    free(buffer);
    
    int total = even + odd;
    int cs = total % 10;
    cs = 10 - cs;
    if (cs == 10)
    {
        cs = 0;
    }
    
    return [value stringByAppendingString:[@(cs) stringValue]];
}

@end
