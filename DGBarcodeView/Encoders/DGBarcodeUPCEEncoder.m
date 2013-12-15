//
//  DGBarcodeUPCEEncoder.m
//  DGBarcodeView
//
//  Created by Daniel Cohen Gindi on 1/31/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGBarcodeUPCEEncoder.h"

@implementation DGBarcodeUPCEEncoder

- (NSString *)encodedValueWithValue:(NSString *)value
{
    static NSString * EAN_CodeA[] = { @"0001101", @"0011001", @"0010011", @"0111101", @"0100011", @"0110001", @"0101111", @"0111011", @"0110111", @"0001011" };
    static NSString * EAN_CodeB[] = { @"0100111", @"0110011", @"0011011", @"0100001", @"0011101", @"0111001", @"0000101", @"0010001", @"0001001", @"0010111" };
    static NSString * UPCE_Code_0[] = { @"bbbaaa", @"bbabaa", @"bbaaba", @"bbaaab", @"babbaa", @"baabba", @"baaabb", @"bababa", @"babaab", @"baabab" };
    static NSString * UPCE_Code_1[] = { @"aaabbb", @"aababb", @"aabbab", @"aabbba", @"abaabb", @"abbaab", @"abbbaa", @"ababab", @"ababba", @"abbaba" };
    
    if ((value.length != 6 && value.length != 8 && value.length != 12) || ![self isNumeric:value])
    {
#if (DEBUG)
        NSLog(@"DGBarcodeEncoder UPCE: Must be 6, 8 or 12 digits");
#endif
        return nil;
    }
    
    unichar *buffer = malloc(sizeof(unichar) * (value.length + 1));
    [value getCharacters:buffer];
    
    int checkDigit = (buffer[value.length-1] - L'0');
    int numberSystem = (buffer[0] - L'0');
    
    if (value.length == 12)
    {
        NSMutableString* UPCECode = [[NSMutableString alloc] init];
        
        NSString *manufacturer = [value substringWithRange:NSMakeRange(1, 5)];
        NSString *productCodeString = [value substringWithRange:NSMakeRange(6, 5)];
        int productCode = [productCodeString intValue];
        
        if (numberSystem != 0 && numberSystem != 1)
        {
            free(buffer);
#if (DEBUG)
            NSLog(@"DGBarcodeEncoder UPCE: Error converting UPCA to UPCE");
#endif
            return nil;
        }
        
        if ([manufacturer hasSuffix:@"000"] ||
            [manufacturer hasSuffix:@"100"] ||
            ([manufacturer hasSuffix:@"200"] &&
             productCode <= 999))
        {
            [UPCECode appendString:[manufacturer substringWithRange:NSMakeRange(0, 2)]];
            [UPCECode appendString:[productCodeString substringWithRange:NSMakeRange(2, 3)]];
            [UPCECode appendString:[manufacturer substringWithRange:NSMakeRange(2, 1)]];
        }
        else if ([manufacturer hasSuffix:@"00"] && productCode <= 99)
        {
            [UPCECode appendString:[manufacturer substringWithRange:NSMakeRange(0, 3)]];
            [UPCECode appendString:[productCodeString substringWithRange:NSMakeRange(3, 2)]];
            [UPCECode appendString:@"3"];
        }
        else if ([manufacturer hasSuffix:@"0"] && productCode <= 9)
        {
            [UPCECode appendString:[manufacturer substringWithRange:NSMakeRange(0, 4)]];
            [UPCECode appendString:[productCodeString substringWithRange:NSMakeRange(4, 1)]];
            [UPCECode appendString:@"4"];
        }
        else if (![manufacturer hasSuffix:@"0"] && productCode <= 9 && productCode >= 5)
        {
            [UPCECode appendString:manufacturer];
            [UPCECode appendString:[productCodeString substringWithRange:NSMakeRange(4,1)]];
        }
        else
        {
            free(buffer);
#if (DEBUG)
            NSLog(@"DGBarcodeEncoder UPCE: Error converting UPCA to UPCE");
#endif
            return nil;
        }
        
        value = UPCECode;
        
        free(buffer);
        
        buffer = malloc(sizeof(unichar) * (value.length + 1));
        [value getCharacters:buffer];
    }
    
    NSString *pattern = (numberSystem==0?UPCE_Code_0:UPCE_Code_1)[checkDigit];
    unichar *patternBuffer = malloc(sizeof(unichar) * (pattern.length + 1));
    [pattern getCharacters:patternBuffer];
    
    NSMutableString *result = [[NSMutableString alloc] initWithString:@"101"];
    
    unichar c;
    for (int i=0; i<pattern.length; i++)
    {
        c = patternBuffer[i];
        if (c == L'a')
        {
            [result appendString:EAN_CodeA[buffer[i] - L'0']];
        }
        else if (c == L'b')
        {
            [result appendString:EAN_CodeB[buffer[i] - L'0']];
        }
    }
    
    free(patternBuffer);
    free(buffer);
    
    [result appendString:@"010101"];
    
    return [result copy];
}

@end
