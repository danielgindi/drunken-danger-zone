//
//  DGBarcodeStandard2of5Encoder.m
//  DGBarcodeView
//
//  Created by Daniel Cohen Gindi on 1/31/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGBarcodeStandard2of5Encoder.h"

@implementation DGBarcodeStandard2of5Encoder

- (NSString *)encodedValueWithValue:(NSString *)value
{
    static NSString * S25_Code[] = { @"11101010101110", @"10111010101110", @"11101110101010", @"10101110101110", @"11101011101010", @"10111011101010", @"10101011101110", @"10101110111010", @"11101010111010", @"10111010111010" };
    
    if (![self isNumeric:value])
    {
#if (DEBUG)
        NSLog(@"DGBarcodeEncoder Standard2of5: May contain digits only");
#endif
        return nil;
    }
    
    NSMutableString *result = [[NSMutableString alloc] initWithString:@"11011010"];
    
    unichar *buffer = malloc(sizeof(unichar) * (value.length + 1));
    [value getCharacters:buffer];
    for (int j=0; j<value.length; j++)
    {
        [result appendString:S25_Code[buffer[j] - L'0']];
    }
    free(buffer);
    
    [result appendString:@"1101011"];
    
    return [result copy];
}

@end
