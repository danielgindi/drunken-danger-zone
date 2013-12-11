//
//  DGBarcodePostNetEncoder.m
//  DGBarcodeView
//
//  Created by Daniel Cohen Gindi on 1/31/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGBarcodePostNetEncoder.h"

@implementation DGBarcodePostNetEncoder

- (NSString *)encodedValueWithValue:(NSString *)value
{
    static NSString *POSTNET_Code[] = { @"11000", @"00011", @"00101", @"00110", @"01001", @"01010", @"01100", @"10001", @"10010", @"10100" };
    
    value = [value stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    switch (value.length)
    {
        case 5:
        case 6:
        case 9:
        case 11:
            break;
        default:
        {
#if (DEBUG)
            NSLog(@"DGBarcodeEncoder PostNet: Must be 5, 6, 9 or 11 digits");
#endif
        }
            return nil;
    }
    
    NSMutableString *result = [[NSMutableString alloc] initWithString:@"1"];
    int checkdigitsum = 0;
    
    unichar *buffer = malloc(sizeof(unichar) * (value.length + 1));
    [value getCharacters:buffer];
    
    unichar c;
    for (int j=0; j<value.length; j++)
    {
        c = buffer[j];
        if (c < L'0' || c > L'9')
        {
            free(buffer);
#if (DEBUG)
            NSLog(@"DGBarcodeEncoder PostNet: May contain digits only");
#endif
            return nil;
        }
        c -= L'0';
        [result appendString:POSTNET_Code[c]];
        checkdigitsum += (int)c;
    }
    
    free(buffer);
    
    int temp = checkdigitsum % 10;
    int checkdigit = 10 - (temp == 0 ? 10 : temp);
    
    [result appendString:POSTNET_Code[checkdigit]];
    
    [result appendString:@"1"];
    
    return [result copy];
}

@end
