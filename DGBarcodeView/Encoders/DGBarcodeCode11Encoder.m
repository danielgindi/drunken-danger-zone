//
//  DGBarcodeCode11Encoder.m
//  DGBarcodeView
//
//  Created by Daniel Cohen Gindi on 1/31/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGBarcodeCode11Encoder.h"

@implementation DGBarcodeCode11Encoder

- (NSString *)encodedValueWithValue:(NSString *)value
{
    static NSString *C11_Code[] = { @"101011", @"1101011", @"1001011", @"1100101", @"1011011", @"1101101", @"1001101", @"1010011", @"1101001", @"110101", @"101101", @"1011001" };
    
    if (![self isNumericAndDashes:value])
    {
#if (DEBUG)
        NSLog(@"DGBarcodeEncoder Code11: May only contain digits and/or dashes");
#endif
        return nil;
    }
    
    unichar *buffer = malloc(sizeof(unichar) * (value.length + 1));
    [value getCharacters:buffer];
    
    int weight = 1;
    int CTotal = 0;
    NSMutableString *Data_To_Encode_with_Checksums = [[NSMutableString alloc] initWithString:value];
    
    for (NSInteger i = value.length - 1; i >= 0; i--)
    {
        if (weight == 10)
        {
            weight = 1;
        }
        
        if (buffer[i] != L'-')
        {
            CTotal += ((int)(buffer[i] - L'0')) * weight++;
        }
        else
        {
            CTotal += 10 * weight++;
        }
    }
    
    int checksumC = CTotal % 11;
    
    [Data_To_Encode_with_Checksums appendString:[@(checksumC) stringValue]];
    
    if (value.length >= 1)
    {
        weight = 1;
        int KTotal = 0;
        unichar c;
        
        for (NSInteger i = Data_To_Encode_with_Checksums.length - 1; i >= 0; i--)
        {
            if (weight == 9)
            {
                weight = 1;
            }
            
            c = [Data_To_Encode_with_Checksums characterAtIndex:i];
            if (c != L'-')
            {
                KTotal += ((int)(c - L'0')) * weight++;
            }
            else
            {
                KTotal += 10 * weight++;
            }
        }
        int checksumK = KTotal % 11;
        [Data_To_Encode_with_Checksums appendString:[@(checksumK) stringValue]];
    }
    
    NSMutableString *result = [[NSMutableString alloc] initWithString:C11_Code[11]];
    [result appendString:@"0"];
    
    free(buffer);
    buffer = malloc(sizeof(unichar) * (Data_To_Encode_with_Checksums.length + 1));
    [Data_To_Encode_with_Checksums getCharacters:buffer];
    
    unichar c;
    for (NSInteger j = 0, len = Data_To_Encode_with_Checksums.length; j < len; j++)
    {
        c = buffer[j];
        [result appendString:C11_Code[(c == '-' ? 10 : ((int)(c - L'0')))]];
        [result appendString:@"0"];
    }
    
    [result appendString:C11_Code[11]];
    
    free(buffer);
    
    return [result copy];
}

@end
