//
//  DGBarcodeUPCAEncoder.m
//  DGBarcodeView
//
//  Created by Daniel Cohen Gindi on 1/31/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGBarcodeUPCAEncoder.h"

@implementation DGBarcodeUPCAEncoder

- (NSString *)encodedValueWithValue:(NSString *)value
{
    return [self encodedValueWithValue:value country:nil];
}

- (NSString *)encodedValueWithValue:(NSString *)value country:(out NSString **)country
{
    static NSString *UPC_CodeA[] = { @"0001101", @"0011001", @"0010011", @"0111101", @"0100011", @"0110001", @"0101111", @"0111011", @"0110111", @"0001011" };
    static NSString *UPC_CodeB[] = { @"1110010", @"1100110", @"1101100", @"1000010", @"1011100", @"1001110", @"1010000", @"1000100", @"1001000", @"1110100" };
    
    if ((value.length != 11 && value.length != 12) || ![self isNumeric:value])
    {
#if (DEBUG)
        NSLog(@"DGBarcodeEncoder UPCA: Must be 11 or 12 digits");
#endif
        return nil;
    }
    
    value = [self valueWithCheckDigitOfValue:value];
    
    unichar *buffer = malloc(sizeof(unichar) * (value.length + 1));
    [value getCharacters:buffer];
    
    NSMutableString *result = [[NSMutableString alloc] initWithString:@"101"];
    [result appendString:UPC_CodeA[((int)(buffer[0] - L'0'))]];
    
    for (int i=1; i<=5; i++)
    {
        [result appendString:UPC_CodeA[((int)(buffer[i] - L'0'))]];
    }
    
    [result appendString:@"01010"];
    
    for (int i=6; i<=10; i++)
    {
        [result appendString:UPC_CodeB[((int)(buffer[i] - L'0'))]];
    }
    
    [result appendString:UPC_CodeB[((int)(buffer[value.length - 1] - L'0'))]];
    
    [result appendString:@"101"];
    
    if (country)
    {
        NSString *twoDigitCode = [@"0" stringByAppendingString:[value substringToIndex:1]];
        *country = self.countryCodesMap[twoDigitCode];
    }
    
    free(buffer);
    
    return [result copy];
}

- (NSString *)valueWithCheckDigitOfValue:(NSString *)value
{
    value = [value substringToIndex:11];
    unichar *buffer = malloc(sizeof(unichar) * (value.length + 1));
    [value getCharacters:buffer];
    
    int even = 0;
    int odd = 0;
    
    for (int i = 0; i < value.length; i++)
    {
        if (i % 2 == 0)
        {
            odd += ((int)(buffer[i] - L'0')) * 3;
        }
        else
        {
            even += ((int)(buffer[i] - L'0'));
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
