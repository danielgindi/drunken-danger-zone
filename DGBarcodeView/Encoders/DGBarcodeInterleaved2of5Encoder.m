//
//  DGBarcodeInterleaved2of5Encoder.m
//  DGBarcodeView
//
//  Created by Daniel Cohen Gindi on 1/31/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGBarcodeInterleaved2of5Encoder.h"

@implementation DGBarcodeInterleaved2of5Encoder

- (NSString *)encodedValueWithValue:(NSString *)value
{
    static NSString *I25_Code[] = { @"NNWWN", @"WNNNW", @"NWNNW", @"WWNNN", @"NNWNW", @"WNWNN", @"NWWNN", @"NNNWW", @"WNNWN", @"NWNWN" };
    
    if (value.length % 2 != 0 || ![self isNumeric:value])
    {
#if (DEBUG)
        NSLog(@"DGBarcodeEncoder Interleaved2of5: Must have even digits count, and contain only digits");
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
    
    for (int i = 0, len, j; i < value.length; i += 2)
    {
        bars = true;
        patternbars = I25_Code[buffer[i] - L'0'];
        patternspaces = I25_Code[buffer[i+1] - L'0'];
        
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

@end
