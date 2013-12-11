//
//  DGBarcodeCodebarEncoder.m
//  DGBarcodeView
//
//  Created by Daniel Cohen Gindi on 1/31/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGBarcodeCodebarEncoder.h"

@implementation DGBarcodeCodebarEncoder

- (NSString *)encodedValueWithValue:(NSString *)value
{
    static NSDictionary *Codabar_Code = nil;
    if (!Codabar_Code)
    {
        Codabar_Code = @{
        @(L'0'): @"101010011",
        @(L'1'): @"101011001",
        @(L'2'): @"101001011",
        @(L'3'): @"110010101",
        @(L'4'): @"101101001",
        @(L'5'): @"110101001",
        @(L'6'): @"100101011",
        @(L'7'): @"100101101",
        @(L'8'): @"100110101",
        @(L'9'): @"110100101",
        @(L'-'): @"101001101",
        @(L'$'): @"101100101",
        @(L':'): @"1101011011",
        @(L'/'): @"1101101011",
        @(L'.'): @"1101101101",
        @(L'+'): @"101100110011",
        @(L'A'): @"1011001001",
        @(L'B'): @"1010010011",
        @(L'C'): @"1001001011",
        @(L'D'): @"1010011001",
        @(L'a'): @"1011001001",
        @(L'b'): @"1010010011",
        @(L'c'): @"1001001011",
        @(L'd'): @"1010011001",
        };
    }
    
    if (value.length < 2)
    {
#if (DEBUG)
        NSLog(@"DGBarcodeEncoder Codebar: Must contain more than 1 character");
#endif
        return nil;
    }
    
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    unichar *buffer = malloc(sizeof(unichar) * (value.length + 1));
    [value getCharacters:buffer];
    
    switch (buffer[0])
    {
        case L'A': case L'a': break;
        case L'B': case L'b': break;
        case L'C': case L'c': break;
        case L'D': case L'd': break;
        default:
            free(buffer);
#if (DEBUG)
            NSLog(@"DGBarcodeEncoder Codebar: May only start with A, B, C or D characters");
#endif
            return nil;
    }
    
    switch (buffer[value.length - 1])
    {
        case L'A': case L'a': break;
        case L'B': case L'b': break;
        case L'C': case L'c': break;
        case L'D': case L'd': break;
        default:
            free(buffer);
#if (DEBUG)
            NSLog(@"DGBarcodeEncoder Codebar: May only start with A, B, C or D characters");
#endif
            return nil;
    }
    
    NSString *temp = [value substringWithRange:NSMakeRange(1, value.length - 2)];
    if (![self isNumeric:temp])
    {
        free(buffer);
#if (DEBUG)
        NSLog(@"DGBarcodeEncoder Codebar: Encountered an non-digit character after code prefix");
#endif
        return nil;
    }
    
    NSMutableString *result = [[NSMutableString alloc] init];
    
    for (int i = 0; i < value.length; i++)
    {
        [result appendString:Codabar_Code[@(buffer[i])]];
        [result appendString:@"0"];
    }
    
    free(buffer);
    
    [result deleteCharactersInRange:NSMakeRange(result.length - 1, 1)];
    
    return [result copy];
}

@end
