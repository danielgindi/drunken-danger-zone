//
//  NSString+Javascript.m
//  Additions
//
//  Created by Daniel Cohen Gindi on 1/5/14.
//  Copyright (c) 2014 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "NSString+Javascript.h"

@implementation NSString (Javascript)

- (unsigned char)hexCharFromInt:(int)value
{
    if (value <= 9) return (unsigned char)(value + 48);
    return (unsigned char)((value - 10) + 97);
}

- (NSString *)unicodeStringForChar:(unichar)ch
{
    unsigned char uni[] = {
        [self hexCharFromInt:((ch >> 12) & 0x0f)],
        [self hexCharFromInt:((ch >> 8) & 0x0f)],
        [self hexCharFromInt:((ch >> 4) & 0x0f)],
        [self hexCharFromInt:(ch & 0x0f)],
        0
    };
    return [NSString stringWithUTF8String:(char*)uni];
}

- (NSString *)stringByEscapingForJavascriptWithDelimiter:(unichar)delimiter wrapWithDelimiters:(BOOL)wrap
{
    NSMutableString *js = [[NSMutableString alloc] init];
    
    if (wrap)
    {
        [js appendFormat:@"%C", delimiter];
    }
    
    int lastWritePosition = 0;
    int skipped = 0;
    int length = self.length;
    unichar *chars = malloc(sizeof(unichar) * length);
    unichar c;
    [self getCharacters:chars range:NSMakeRange(0, length)];
    NSString *escapedValue;
    
    for (int i = 0; i < length; i++)
    {
        c = chars[i];
        
        switch (c)
        {
            case L'\t':
            escapedValue = @"\\t";
            break;
            case L'\n':
            escapedValue = @"\\n";
            break;
            case L'\r':
            escapedValue = @"\\r";
            break;
            case L'\f':
            escapedValue = @"\\f";
            break;
            case L'\b':
            escapedValue = @"\\b";
            break;
            case L'\\':
            escapedValue = @"\\\\";
            break;
            case 0x0085:
            escapedValue = @"\\u0085";
            break;
            case 0x2028:
            escapedValue = @"\\u2028";
            break;
            case 0x2029:
            escapedValue = @"\\u2029";
            break;
            case L'\'':
            escapedValue = (delimiter == L'\'') ? @"\\'" : nil;
            break;
            case L'"':
            escapedValue = (delimiter == '"') ? @"\\\"" : nil;
            break;
            default:
            escapedValue = (c <= 0x001f) ? [self unicodeStringForChar:c] : nil;
            break;
        }
        
        if (escapedValue)
        {
            if (skipped > 0)
            {
                [js appendString:[self substringWithRange:NSMakeRange(lastWritePosition, skipped)]];
                skipped = 0;
            }
            
            [js appendString:escapedValue];
            lastWritePosition = i + 1;
        }
        else
        {
            skipped++;
        }
    }
    
    if (skipped > 0)
    {
        if (lastWritePosition == 0)
        {
            [js appendString:self];
        }
        else
        {
            [js appendString:[self substringWithRange:NSMakeRange(lastWritePosition, skipped)]];
        }
    }
    
    free(chars);
    
    if (wrap)
    {
        [js appendFormat:@"%C", delimiter];
    }
    
    return js;
}

@end
