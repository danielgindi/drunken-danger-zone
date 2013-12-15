//
//  DGBarcodeUPCSupplement5Encoder.m
//  DGBarcodeView
//
//  Created by Daniel Cohen Gindi on 1/31/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGBarcodeUPCSupplement5Encoder.h"

@implementation DGBarcodeUPCSupplement5Encoder

- (NSString*)encodedValueWithValue:(NSString*)value
{
    static NSString *EAN_CodeA[] = { @"0001101", @"0011001", @"0010011", @"0111101", @"0100011", @"0110001", @"0101111", @"0111011", @"0110111", @"0001011" };
    static NSString *EAN_CodeB[] = { @"0100111", @"0110011", @"0011011", @"0100001", @"0011101", @"0111001", @"0000101", @"0010001", @"0001001", @"0010111" };
    static NSString *UPC_SUPP_5[] = { @"bbaaa", @"babaa", @"baaba", @"baaab", @"abbaa", @"aabba", @"aaabb", @"ababa", @"abaab", @"aabab" };
    
    if (value.length != 5 || ![self isNumeric:value])
    {
#if (DEBUG)
        NSLog(@"DGBarcodeEncoder UPCSupplement5: Must contain 5 digits exactly");
#endif
        return nil;
    }
    
    unichar *buffer = malloc(sizeof(unichar) * (value.length + 1));
    [value getCharacters:buffer];
    
    int even = 0;
    int odd = 0;
    
    for (int i = 0; i <= 4; i += 2)
    {
        odd += ((int)(buffer[i] - L'0')) * 3;
    }
    
    for (int i = 1; i < 4; i += 2)
    {
        even += ((int)(buffer[i] - L'0')) * 9;
    }
    
    int total = even + odd;
    int cs = total % 10;
    
    NSString* pattern = UPC_SUPP_5[cs];
    
    NSMutableString *result = [[NSMutableString alloc] init];
    
    unichar c;
    for (int j=0; j<pattern.length; j++)
    {
        c = [pattern characterAtIndex:j];
        if (j == 0)
        {
            [result appendString:@"1011"];
        }
        else
        {
            [result appendString:@"01"];
        }
        
        if (c == L'a')
        {
            [result appendString:EAN_CodeA[buffer[j] - L'0']];
        }
        else if (c == L'b')
        {
            [result appendString:EAN_CodeB[buffer[j] - L'0']];
        }
    }
    
    free(buffer);
    
    return [result copy];
}

@end
