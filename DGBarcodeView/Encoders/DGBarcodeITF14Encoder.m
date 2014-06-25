//
//  DGBarcodeITF14Encoder.m
//  DGBarcodeView
//
//  Created by Daniel Cohen Gindi on 1/31/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGBarcodeITF14Encoder.h"

@implementation DGBarcodeITF14Encoder

- (NSString *)encodedValueWithValue:(NSString *)value
{
    static NSString *ITF14_Code[] = { @"NNWWN", @"WNNNW", @"NWNNW", @"WWNNN", @"NNWNW", @"WNWNN", @"NWWNN", @"NNNWW", @"WNNWN", @"NWNWN" };
    
    if (value.length > 14 || value.length < 13 || ![self isNumeric:value])
    {
#if (DEBUG)
        NSLog(@"DGBarcodeEncoder ITF14: Must be 13 or 14 digits");
#endif
        return nil;
    }
    
    unichar *buffer = malloc(sizeof(unichar) * (value.length + 1));
    [value getCharacters:buffer];
    
    NSMutableString *result = [[NSMutableString alloc] initWithString:@"1010"];
    
    NSString *patternbars, *patternspaces;
    NSMutableString *patternmixed = [[NSMutableString alloc] init];
    
    unichar *mixedBuffer = malloc(sizeof(unichar) * (value.length * 5 + 1));
    unichar c;
    bool bars;
    
    for (NSInteger i = 0, len, j; i < value.length; i += 2)
    {
        bars = true;
        patternbars = ITF14_Code[buffer[i] - L'0'];
        patternspaces = ITF14_Code[buffer[i+1] - L'0'];
        
        if (patternmixed.length)
        {
            [patternmixed deleteCharactersInRange:NSMakeRange(0, patternmixed.length)];
        }
        
        for (j = 0, len = patternbars.length; j < len; j++)
        {
            [patternmixed appendString:[patternbars substringWithRange:NSMakeRange(j, 1)]];
            [patternmixed appendString:[patternspaces substringWithRange:NSMakeRange(j, 1)]];
        }
        
        [patternmixed getCharacters:mixedBuffer];
        
        for (j = 0, len = patternmixed.length; j < len; j++)
        {
            c = mixedBuffer[j];
            if (bars)
            {
                if (c == 'N')
                {
                    [result appendString:@"1"];
                }
                else
                {
                    [result appendString:@"11"];
                }
            }
            else
            {
                if (c == 'N')
                {
                    [result appendString:@"0"];
                }
                else
                {
                    [result appendString:@"00"];
                }
            }
            bars = !bars;
        }
    }
    
    free(mixedBuffer);
    free(buffer);
    
    [result appendString:@"1101"];
    
    return [result copy];
}

- (NSString *)valueWithCheckDigitOfValue:(NSString *)value
{
    if (value.length == 13)
    {
        unichar *buffer = malloc(sizeof(unichar) * (value.length + 1));
        [value getCharacters:buffer];
        
        int even = 0;
        int odd = 0;
        
        for (int i = 0; i <= 10; i += 2)
        {
            odd += ((int)(buffer[i] - L'0'));
        }
        
        for (int i = 1; i <= 11; i += 2)
        {
            even += ((int)(buffer[i] - L'0')) * 3;
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
