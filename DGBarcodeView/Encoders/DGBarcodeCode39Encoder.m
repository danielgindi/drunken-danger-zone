//
//  DGBarcodeCode39Encoder.m
//  DGBarcodeView
//
//  Created by Daniel Cohen Gindi on 1/31/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGBarcodeCode39Encoder.h"

@interface DGBarcodeCode39Encoder ()
{
    BOOL _allowExtended;
}
@end

@implementation DGBarcodeCode39Encoder

- (id)initWithAllowExtended:(BOOL)allowExtended
{
    self = [super init];
    if (self)
    {
        _allowExtended = allowExtended;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _allowExtended = NO;
    }
    return self;
}

- (NSString *)encodedValueWithValue:(NSString *)value
{
    return [self encodedValueWithValue:value allowExtended:_allowExtended];
}

- (NSString *)encodedValueWithValue:(NSString *)value allowExtended:(BOOL)allowExtended
{
    if (!allowExtended)
    {
        value = [value uppercaseString];
    }
    
    value = [value stringByReplacingOccurrencesOfString:@"*" withString:@""];
    
    NSMutableString *result = [[NSMutableString alloc] initWithCapacity:value.length];
    
    if (![self codeCharacter:L'*' intoString:result allowExtended:allowExtended])
    {
#if (DEBUG)
        NSLog(@"DGBarcodeEncoder Code39: Encountered an unexpected character. Maybe try the extended mode.");
#endif
        return nil;
    }
    [result appendString:@"0"];
    
    for (int j = 0, len = value.length; j < len; j++)
    {
        if (![self codeCharacter:[value characterAtIndex:j] intoString:result allowExtended:allowExtended])
        {
#if (DEBUG)
            NSLog(@"DGBarcodeEncoder Code39: Encountered an unexpected character. Maybe try the extended mode.");
#endif
            return nil;
        }
        
        [result appendString:@"0"];
    }
    
    if (![self codeCharacter:L'*' intoString:result allowExtended:allowExtended])
    {
#if (DEBUG)
        NSLog(@"DGBarcodeEncoder Code39: Encountered an unexpected character. Maybe try the extended mode.");
#endif
        return nil;
    }

    return [result copy];
}

- (BOOL)codeCharacter:(unichar)character intoString:(NSMutableString*)output allowExtended:(BOOL)allowExtended
{
    static NSDictionary *codeMap = nil;
    if (!codeMap)
    {
        codeMap = self.codeMap;
    }
    
    static NSDictionary *codeExtendedMap = nil;
    if (!codeExtendedMap)
    {
        codeExtendedMap = self.codeExtendedMap;
    }
    
    NSString *cc = codeMap[@(character)];
    if (cc)
    {
        [output appendString:cc];
        return YES;
    }
    else if (allowExtended)
    {
        NSString *escapedCode = codeExtendedMap[@(character)];
        if (escapedCode)
        {
            for (int j=0, len = escapedCode.length; j<len; j++)
            {
                if (![self codeCharacter:[escapedCode characterAtIndex:j] intoString:output allowExtended:allowExtended])
                {
                    return NO;
                }
                if (j < len - 1)
                {
                    [output appendString:@"0"];
                }
            }
            return YES;
        }
        else
        {
            return NO;
        }
    }
    else
    {
        return NO;
    }
}

- (NSDictionary*)codeMap
{
    static NSDictionary *codeMap = nil;
    if (!codeMap)
    {
        codeMap = @{
        @(L'0'): @"101001101101",
        @(L'1'): @"110100101011",
        @(L'2'): @"101100101011",
        @(L'3'): @"110110010101",
        @(L'4'): @"101001101011",
        @(L'5'): @"110100110101",
        @(L'6'): @"101100110101",
        @(L'7'): @"101001011011",
        @(L'8'): @"110100101101",
        @(L'9'): @"101100101101",
        @(L'A'): @"110101001011",
        @(L'B'): @"101101001011",
        @(L'C'): @"110110100101",
        @(L'D'): @"101011001011",
        @(L'E'): @"110101100101",
        @(L'F'): @"101101100101",
        @(L'G'): @"101010011011",
        @(L'H'): @"110101001101",
        @(L'I'): @"101101001101",
        @(L'J'): @"101011001101",
        @(L'K'): @"110101010011",
        @(L'L'): @"101101010011",
        @(L'M'): @"110110101001",
        @(L'N'): @"101011010011",
        @(L'O'): @"110101101001",
        @(L'P'): @"101101101001",
        @(L'Q'): @"101010110011",
        @(L'R'): @"110101011001",
        @(L'S'): @"101101011001",
        @(L'T'): @"101011011001",
        @(L'U'): @"110010101011",
        @(L'V'): @"100110101011",
        @(L'W'): @"110011010101",
        @(L'X'): @"100101101011",
        @(L'Y'): @"110010110101",
        @(L'Z'): @"100110110101",
        @(L'-'): @"100101011011",
        @(L'.'): @"110010101101",
        @(L' '): @"100110101101",
        @(L'$'): @"100100100101",
        @(L'/'): @"100100101001",
        @(L'+'): @"100101001001",
        @(L'%'): @"101001001001",
        @(L'*'): @"100101101101",
        };
    }
    return codeMap;
}

- (NSDictionary*)codeExtendedMap
{
    static NSDictionary *codeExtendedMap = nil;
    if (!codeExtendedMap)
    {
        codeExtendedMap = @{
            @(L'\x00'): @"%U",
            @(L'\x01'): @"$A",
            @(L'\x02'): @"$B",
            @(L'\x03'): @"$C",
            @(L'\x04'): @"$D",
            @(L'\x05'): @"$E",
            @(L'\x06'): @"$F",
            @(L'\x07'): @"$G",
            @(L'\x08'): @"$H",
            @(L'\x09'): @"$I",
            @(L'\x0A'): @"$J",
            @(L'\x0B'): @"$K",
            @(L'\x0C'): @"$L",
            @(L'\x0D'): @"$M",
            @(L'\x0E'): @"$N",
            @(L'\x0F'): @"$O",
            @(L'\x10'): @"$P",
            @(L'\x11'): @"$Q",
            @(L'\x12'): @"$R",
            @(L'\x13'): @"$S",
            @(L'\x14'): @"$T",
            @(L'\x15'): @"$U",
            @(L'\x16'): @"$V",
            @(L'\x17'): @"$W",
            @(L'\x18'): @"$X",
            @(L'\x19'): @"$Y",
            @(L'\x1A'): @"$Z",
            @(L'\x1B'): @"%A",
            @(L'\x1C'): @"%B",
            @(L'\x1D'): @"%C",
            @(L'\x1E'): @"%D",
            @(L'\x1F'): @"%E",
            @(L'!'): @"/A",
            @(L'\"'): @"/B",
            @(L'#'): @"/C",
            @(L'$'): @"/D",
            @(L'%'): @"/E",
            @(L'&'): @"/F",
            @(L'\''): @"/G",
            @(L'('): @"/H",
            @(L')'): @"/I",
            @(L'*'): @"/J",
            @(L'+'): @"/K",
            @(L','): @"/L",
            @(L'/'): @"/O",
            @(L':'): @"/Z",
            @(L';'): @"%F",
            @(L'<'): @"%G",
            @(L'='): @"%H",
            @(L'>'): @"%I",
            @(L'?'): @"%J",
            @(L'['): @"%K",
            @(L'\\'): @"%L",
            @(L']'): @"%M",
            @(L'^'): @"%N",
            @(L'_'): @"%O",
            @(L'{'): @"%P",
            @(L'|'): @"%Q",
            @(L'}'): @"%R",
            @(L'~'): @"%S",
            @(L'`'): @"%W",
            @(L'@'): @"%V",
            @(L'a'): @"+A",
            @(L'b'): @"+B",
            @(L'c'): @"+C",
            @(L'd'): @"+D",
            @(L'e'): @"+E",
            @(L'f'): @"+F",
            @(L'g'): @"+G",
            @(L'h'): @"+H",
            @(L'i'): @"+I",
            @(L'j'): @"+J",
            @(L'k'): @"+K",
            @(L'l'): @"+L",
            @(L'm'): @"+M",
            @(L'n'): @"+N",
            @(L'o'): @"+O",
            @(L'p'): @"+P",
            @(L'q'): @"+Q",
            @(L'r'): @"+R",
            @(L's'): @"+S",
            @(L't'): @"+T",
            @(L'u'): @"+U",
            @(L'v'): @"+V",
            @(L'w'): @"+W",
            @(L'x'): @"+X",
            @(L'y'): @"+Y",
            @(L'z'): @"+Z",
            @(L'\x7f'): @"%T", // or %X, %Y, %Z. Doesn't matter
        };
    }
    return codeExtendedMap;
}

@end
