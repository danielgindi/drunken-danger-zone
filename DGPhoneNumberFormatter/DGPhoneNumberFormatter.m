//
// DGPhoneNumberFormatter.m
// DGPhoneNumberFormatter
// v1.0.1
//
//  Created by Daniel Cohen Gindi on 5/4/12.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGPhoneNumberFormatter.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

typedef enum _DGPhoneNumberFormatterCountryType
{
    DGPhoneNumberFormatterCountryTypeUsAndCanada,
    DGPhoneNumberFormatterCountryTypeOther
} DGPhoneNumberFormatterCountryType;

@interface DGPhoneNumberFormatter (Private)

- (NSString *)parseString:(NSString *)input;
- (NSString *)parseLastSevenDigits:(NSString *)basicNumber;

- (NSString *)stripNonPhone:(NSString *)input;
- (NSUInteger)formattedNewLocationFromOldFormatted:(NSString *)formattedOld formattedNew:(NSString *)formattedNew formattedOldLocation:(NSUInteger)formattedOldLocation lengthAdded:(NSUInteger)lengthAdded;

@end

@implementation DGPhoneNumberFormatter

- (NSString *)stringForObjectValue:(id)anObject
{
    if (![anObject isKindOfClass:[NSString class]]) return nil;
    if ([anObject length] < 1) return nil;
    
    NSString *unformatted = [self stripNonPhone:anObject];
    if (!unformatted.length) return nil;
    
    NSString *firstDigit = [unformatted substringToIndex:1];
    if ([firstDigit isEqualToString:@"*"] || [firstDigit isEqualToString:@"#"])
    {
        return unformatted;
    }
    
    return [self parseString:unformatted];
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error
{
    *anObject = (id)[self stripNonPhone:string];
    return YES;
}

- (NSString *)stripNonPhone:(NSString *)input
{
    NSRegularExpression *rgx = [NSRegularExpression regularExpressionWithPattern:@"[^0-9\\*\\#\\+\\,]" options:0 error:nil];
    return [rgx stringByReplacingMatchesInString:input options:0 range:NSMakeRange(0, input.length) withTemplate:@""];
}

- (NSUInteger)formattedNewLocationFromOldFormatted:(NSString *)formattedOld formattedNew:(NSString *)formattedNew formattedOldLocation:(NSUInteger)formattedOldLocation lengthAdded:(NSUInteger)lengthAdded
{
    NSUInteger unformattedLocationOld = [[self stripNonPhone:[formattedOld substringToIndex:formattedOldLocation]] length];
    NSUInteger unformattedLocationNew = unformattedLocationOld + lengthAdded;
    NSUInteger formattedLocationNew = 0;
    
    while (unformattedLocationNew > 0 && formattedLocationNew < formattedNew.length) {
        unichar currentCharacter = [formattedNew characterAtIndex:formattedLocationNew];
        if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:currentCharacter]) {
            unformattedLocationNew--;
        }
        
        formattedLocationNew++;
    }
    
    return formattedLocationNew;
}

- (BOOL)isPartialStringValid:(NSString **)partialStringPtr proposedSelectedRange:(NSRangePointer)proposedSelRangePtr originalString:(NSString *)origString originalSelectedRange:(NSRange)origSelRange errorDescription:(NSString **)error
{
    NSString *formattedOld = origString;
    NSString *proposedNewString = *partialStringPtr;
    NSString *formattedNew = [self stringForObjectValue:proposedNewString];
    NSUInteger formattedLocationNew = 0;
    NSUInteger lengthAdded = 0;
    
    if (formattedOld.length > proposedNewString.length) { // removing characters
        lengthAdded = -(origSelRange.location - (*proposedSelRangePtr).location);
    } else if (formattedOld.length < proposedNewString.length) { // adding characters
        lengthAdded = (*proposedSelRangePtr).location - origSelRange.location;
    } else { // replace characters
        lengthAdded = origSelRange.length;
    }
    
    formattedLocationNew = [self formattedNewLocationFromOldFormatted:formattedOld formattedNew:formattedNew formattedOldLocation:origSelRange.location lengthAdded:lengthAdded];
    
    *partialStringPtr = formattedNew;
    *proposedSelRangePtr = NSMakeRange(formattedLocationNew, (*proposedSelRangePtr).length);
    
    return NO;
}

- (NSString *)parseLocalNumber:(NSString*)number withKnownCountryCode:(NSString*)countryCode
{
    if (!number.length) return nil;
    
    NSMutableString *output = [NSMutableString string];
    
    DGPhoneNumberFormatterCountryType countryType = DGPhoneNumberFormatterCountryTypeOther;
    
    if (countryCode.length)
    {
        if ([countryCode isEqualToString:@"1"])
        {
            countryType = DGPhoneNumberFormatterCountryTypeUsAndCanada;
        }
    }
    else
    {
        static NSString *localCountryCode = nil;
        if (!localCountryCode.length)
        {
            CTTelephonyNetworkInfo *myNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
            CTCarrier *myCarrier = myNetworkInfo.subscriberCellularProvider;
            localCountryCode = myCarrier.mobileCountryCode;
        }
        if (localCountryCode.length)
        {
            if ([localCountryCode isEqualToString:@"302"] ||
                [localCountryCode isEqualToString:@"310"] ||
                [localCountryCode isEqualToString:@"311"] ||
                [localCountryCode isEqualToString:@"313"] ||
                [localCountryCode isEqualToString:@"316"] ||
                [localCountryCode isEqualToString:@"204"])
            {
                countryType = DGPhoneNumberFormatterCountryTypeUsAndCanada;
            }
        }
    }
    
    if (countryType == DGPhoneNumberFormatterCountryTypeUsAndCanada)
    {
        [output appendString:@"("];
        if (number.length >= 3)
        { // 3 digits of state code
            [output appendString:[number substringToIndex:3]];
            [output appendString:@")"];
            number = [number substringFromIndex:3];
            if (number.length)
            { // Anything beyond state code
                [output appendString:@" "];
                if (number.length > 3)
                { // Area code and body
                    [output appendString:[number substringToIndex:3]];
                    [output appendString:@"-"];
                    [output appendString:[number substringFromIndex:3]];
                }
                else
                { // The rest of it
                    [output appendString:number];
                }
            }
        }
        else
        { // Everything else
            [output appendString:number];
            for (int j=3-number.length; j>0; j--)
            {
                [output appendString:@" "];
            }
            [output appendString:@")"];
        }
    }
    else
    {
        if ([number characterAtIndex:0] == L'0')
        {
            [output appendString:[number substringToIndex:MIN(3, number.length)]];
            if (number.length > 3)
            { // 000-
                number = [number substringFromIndex:3];
                [output appendString:@"-"];
                
                if (number.length > 4)
                { // 0000 000
                    [output appendString:[number substringToIndex:4]];
                    [output appendString:@" "];
                    [output appendString:[number substringFromIndex:4]];
                }
                else
                { // Everything else
                    [output appendString:number];
                }
            }
        }
        else if ([number characterAtIndex:0] == L'1')
        { // 1 0000 000
            [output appendString:[number substringToIndex:1]];
            if (number.length > 1)
            {
                number = [number substringFromIndex:1];
                [output appendString:@" "];
                
                if (number.length > 3)
                { // 0000 000
                    [output appendString:[number substringToIndex:3]];
                    [output appendString:@" "];
                    [output appendString:[number substringFromIndex:3]];
                }
                else
                { // Everything else
                    [output appendString:number];
                }
            }
        }
        else
        { // Everything else
            [output appendString:[number substringToIndex:MIN(2, number.length)]];
            if (number.length > 2)
            { // 000-
                number = [number substringFromIndex:2];
                [output appendString:@"-"];
                
                if (number.length > 4)
                { // 0000 000
                    [output appendString:[number substringToIndex:4]];
                    [output appendString:@" "];
                    [output appendString:[number substringFromIndex:4]];
                }
                else
                { // Everything else
                    [output appendString:number];
                }
            }
        }
    }
    
    return output;
}

- (NSString *)parseString:(NSString *)input
{
    NSString *inputBody = nil;
    NSMutableString *output = [NSMutableString string];
    
    unichar international = 0;
    if (input.length >= 1 && [input characterAtIndex:0] == L'+')
    {
        [output appendString:[input substringToIndex:1]];
        inputBody = [input substringFromIndex:1];
        international = L'+';
    }
    else if (input.length >= 2 && [input characterAtIndex:0] == L'0' && [input characterAtIndex:1] == L'0')
    {
        [output appendString:[input substringToIndex:2]];
        inputBody = [input substringFromIndex:2];
        international = L'0';
    }
    else
    {
        inputBody = input;
    }
    
    if (international)
    {
        NSString *countryCode = [self extractCountryCodeFromNumber:inputBody];
        if (countryCode.length)
        {
            // Remove country code from body
            inputBody = [inputBody substringFromIndex:countryCode.length];
            
            // Append international prefix to output
            if (international == L'0')
            {
                [output appendString:@" "];
            }
            [output appendString:countryCode];
            
            if (inputBody.length)
            {
                [output appendString:@" "];
            }
        }
        
        if (inputBody.length)
        {
            if (countryCode.length >= 2)
            {
                [output appendString:[self parseLocalNumber:inputBody withKnownCountryCode:countryCode]];
            }
            else if (countryCode.length == 1)
            { // Probably US/Canada
                
                [output appendString:@"("];
                if (inputBody.length >= 3)
                { // 3 digits of state code
                    [output appendString:[inputBody substringToIndex:3]];
                    [output appendString:@")"];
                    inputBody = [inputBody substringFromIndex:3];
                    if (inputBody.length)
                    { // Anything beyond state code
                        [output appendString:@" "];
                        if (inputBody.length > 3)
                        { // Area code and body
                            [output appendString:[inputBody substringToIndex:3]];
                            [output appendString:@"-"];
                            [output appendString:[inputBody substringFromIndex:3]];
                        }
                        else
                        { // The rest of it
                            [output appendString:inputBody];
                        }
                    }
                }
                else
                { // Everything else
                    [output appendString:inputBody];
                    for (int j=3-inputBody.length; j>0; j--)
                    {
                        [output appendString:@" "];
                    }
                    [output appendString:@")"];
                }
            }
            else
            { // Everything else
                [output appendString:inputBody];
            }
        }
    }
    else
    {
        [output appendString:[self parseLocalNumber:inputBody withKnownCountryCode:nil]];
    }
    
    return [output copy];
}

- (NSString *)extractCountryCodeFromNumber:(NSString*)number
{
    if (!number.length) return nil;
    
    static NSArray *codes = nil;
    if (!codes)
    {
        NSArray *list = @[
        @"1", @"93", @"355", @"213", @"376", @"244",
        @"672", @"54", @"374", @"297", @"247", @"61",
        @"43", @"994", @"973", @"880", @"375", @"32",
        @"501", @"229", @"975", @"591", @"387", @"267",
        @"55", @"246", @"673", @"359", @"226", @"257",
        @"855", @"237", @"238", @"236", @"235", @"56",
        @"86", @"57", @"269", @"243", @"242", @"682",
        @"506", @"225", @"385", @"53", @"357", @"420",
        @"45", @"253", @"670", @"593", @"20", @"503",
        @"240", @"291", @"372", @"251", @"500", @"298",
        @"679", @"358", @"33", @"594", @"689", @"241",
        @"220", @"970", @"995", @"49", @"233", @"350",
        @"30", @"299", @"590", @"502", @"224", @"245",
        @"592", @"509", @"504", @"852", @"36", @"354",
        @"91", @"62", @"964", @"98", @"353", @"972",
        @"39", @"81", @"962", @"7", @"254", @"686",
        @"965", @"996", @"856", @"371", @"961", @"266",
        @"231", @"218", @"423", @"370", @"352", @"853",
        @"389", @"261", @"265", @"60", @"960", @"223",
        @"356", @"692", @"596", @"222", @"230", @"262",
        @"52", @"691", @"373", @"377", @"976", @"382",
        @"212", @"258", @"95", @"264", @"674", @"31",
        @"599", @"977", @"687", @"64", @"505", @"227",
        @"234", @"683", @"850", @"47", @"968", @"92",
        @"680", @"507", @"675", @"595", @"51", @"63",
        @"48", @"351", @"974", @"40", @"250", @"290",
        @"508", @"685", @"239", @"966", @"221", @"381",
        @"248", @"232", @"65", @"421", @"386", @"677",
        @"252", @"27", @"82", @"211", @"34", @"94",
        @"249", @"597", @"268", @"46", @"41", @"963",
        @"886", @"992", @"255", @"66", @"228", @"690",
        @"676", @"216", @"90", @"993", @"688", @"256",
        @"380", @"971", @"44", @"598", @"998", @"678",
        @"58", @"84", @"681", @"967", @"260", @"263",
        @"3"
        ];
        codes = [[list mutableCopy] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj1 compare:obj2];
        }];
    }
    
    NSString *longestCode = [number substringToIndex:MIN(number.length, 3)];
    while (NSNotFound == [codes indexOfObject:longestCode inSortedRange:NSMakeRange(0, codes.count) options:NSBinarySearchingFirstEqual usingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2)
    {
        return [obj1 compare:obj2];
    }]) {
        longestCode = [longestCode substringToIndex:longestCode.length - 1];
        if (longestCode.length == 0) return nil;
    }
    return longestCode;
}

@end


