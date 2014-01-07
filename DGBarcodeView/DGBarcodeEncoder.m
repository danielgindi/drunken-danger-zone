//
//  DGBarcodeEncoder.m
//  DGBarcodeView
//
//  Created by Daniel Cohen Gindi on 1/31/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//
//  The MIT License (MIT)
//  
//  Copyright (c) 2014 Daniel Cohen Gindi (danielgindi@gmail.com)
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE. 
//  

#import "DGBarcodeEncoder.h"

#import "DGBarcodeUPCAEncoder.h"
#import "DGBarcodeUPCEEncoder.h"
#import "DGBarcodeUPCSupplement2Encoder.h"
#import "DGBarcodeUPCSupplement5Encoder.h"
#import "DGBarcodeCode11Encoder.h"
#import "DGBarcodeCodebarEncoder.h"
#import "DGBarcodeEAN13Encoder.h"
#import "DGBarcodeEAN8Encoder.h"
#import "DGBarcodeFIMEncoder.h"
#import "DGBarcodeInterleaved2of5Encoder.h"
#import "DGBarcodeISBNEncoder.h"
#import "DGBarcodeITF14Encoder.h"
#import "DGBarcodeJAN13Encoder.h"
#import "DGBarcodePostnetEncoder.h"
#import "DGBarcodeStandard2of5Encoder.h"
#import "DGBarcodeCode39Encoder.h"

@implementation DGBarcodeEncoder

+ (DGBarcodeEncoder *)encoderForEncoding:(DGBarcodeEncoding)encoding
{
    switch (encoding)
    {
        default:
            return nil;
        case DGBarcodeEncodingUCC12:
        case DGBarcodeEncodingUPCA:
            return [[DGBarcodeUPCAEncoder alloc] init];
            break;
        case DGBarcodeEncodingUPCE:
            return [[DGBarcodeUPCEEncoder alloc] init];
            break;
        case DGBarcodeEncodingUPCSupplement2:
            return [[DGBarcodeUPCSupplement2Encoder alloc] init];
            break;
        case DGBarcodeEncodingUPCSupplement5:
            return [[DGBarcodeUPCSupplement5Encoder alloc] init];
            break;
        case DGBarcodeEncodingPostNet:
            return [[DGBarcodePostNetEncoder alloc] init];
            break;
        case DGBarcodeEncodingIndustrial2of5:
        case DGBarcodeEncodingStandard2of5:
            return [[DGBarcodeStandard2of5Encoder alloc] init];
            break;
        case DGBarcodeEncodingInterleaved2of5:
            return [[DGBarcodeInterleaved2of5Encoder alloc] init];
            break;
        case DGBarcodeEncodingBOOKLAND:
        case DGBarcodeEncodingISBN:
            return [[DGBarcodeISBNEncoder alloc] init];
            break;
        case DGBarcodeEncodingITF14:
            return [[DGBarcodeITF14Encoder alloc] init];
            break;
        case DGBarcodeEncodingJAN13:
            return [[DGBarcodeJAN13Encoder alloc] init];
            break;
        case DGBarcodeEncodingFIM:
            return [[DGBarcodeFIMEncoder alloc] init];
            break;
        case DGBarcodeEncodingEAN8:
            return [[DGBarcodeEAN8Encoder alloc] init];
            break;
        case DGBarcodeEncodingUCC13:
        case DGBarcodeEncodingEAN13:
            return [[DGBarcodeEAN13Encoder alloc] init];
            break;
        case DGBarcodeEncodingUSD8:
        case DGBarcodeEncodingCode11:
            return [[DGBarcodeCode11Encoder alloc] init];
            break;
        case DGBarcodeEncodingCode39:
            return [[DGBarcodeCode39Encoder alloc] init];
            break;
        case DGBarcodeEncodingCode39Extended:
            return [[DGBarcodeCode39Encoder alloc] initWithAllowExtended:YES];
            break;
    }
}

+ (NSString *)encodedValueWithValue:(NSString *)value inEncoding:(DGBarcodeEncoding)encoding
{
    return [[self encoderForEncoding:encoding] encodedValueWithValue:value];
}

- (NSString *)encodedValueWithValue:(NSString *)value
{
    return nil;
}

- (NSString *)encodedValueWithValue:(NSString *)value country:(out NSString **)country
{
    if (country)
    {
        *country = nil;
    }
    return [self encodedValueWithValue:value];
}

#pragma mark - Utilities

- (BOOL)isNumeric:(NSString *)value
{
    if ([value rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound)
    {
        return NO;
    }
    return YES;
}

- (BOOL)isNumericAndDashes:(NSString *)value
{
    NSMutableCharacterSet *set = [[NSCharacterSet decimalDigitCharacterSet] mutableCopy];
    [set addCharactersInString:@"-"];
    [set invert];
    
    if ([value rangeOfCharacterFromSet:set].location != NSNotFound)
    {
        return NO;
    }
    return YES;
}

- (NSDictionary*)countryCodesMap
{
    static NSDictionary *countryCodesMap = nil;
    if (!countryCodesMap)
    {
        countryCodesMap = @{
        @"00": @"US / CANADA",
        @"01": @"US / CANADA",
        @"02": @"US / CANADA",
        @"03": @"US / CANADA",
        @"04": @"US / CANADA",
        @"05": @"US / CANADA",
        @"06": @"US / CANADA",
        @"07": @"US / CANADA",
        @"08": @"US / CANADA",
        @"09": @"US / CANADA",
        @"10": @"US / CANADA",
        @"11": @"US / CANADA",
        @"12": @"US / CANADA",
        @"13": @"US / CANADA",
        
        @"20": @"IN STORE",
        @"21": @"IN STORE",
        @"22": @"IN STORE",
        @"23": @"IN STORE",
        @"24": @"IN STORE",
        @"25": @"IN STORE",
        @"26": @"IN STORE",
        @"27": @"IN STORE",
        @"28": @"IN STORE",
        @"29": @"IN STORE",
        
        @"30": @"FRANCE",
        @"31": @"FRANCE",
        @"32": @"FRANCE",
        @"33": @"FRANCE",
        @"34": @"FRANCE",
        @"35": @"FRANCE",
        @"36": @"FRANCE",
        @"37": @"FRANCE",
        
        @"40": @"GERMANY",
        @"41": @"GERMANY",
        @"42": @"GERMANY",
        @"43": @"GERMANY",
        @"44": @"GERMANY",
        
        @"45": @"JAPAN",
        @"46": @"RUSSIAN FEDERATION",
        @"49": @"JAPAN (JAN-13)",
        
        @"50": @"UNITED KINGDOM",
        @"54": @"BELGIUM / LUXEMBOURG",
        @"57": @"DENMARK",
        
        @"64": @"FINLAND",
        
        @"70": @"NORWAY",
        @"73": @"SWEDEN",
        @"76": @"SWITZERLAND",
        
        @"80": @"ITALY",
        @"81": @"ITALY",
        @"82": @"ITALY",
        @"83": @"ITALY",
        @"84": @"SPAIN",
        @"87": @"NETHERLANDS",
        
        @"90": @"AUSTRIA",
        @"91": @"AUSTRIA",
        @"93": @"AUSTRALIA",
        @"94": @"NEW ZEALAND",
        @"99": @"COUPONS",
        
        @"380": @"BULGARIA",
        @"383": @"SLOVENIJA",
        @"385": @"CROATIA",
        @"387": @"BOSNIA-HERZEGOVINA",
        
        @"460": @"RUSSIA",
        @"461": @"RUSSIA",
        @"462": @"RUSSIA",
        @"463": @"RUSSIA",
        @"464": @"RUSSIA",
        @"465": @"RUSSIA",
        @"466": @"RUSSIA",
        @"467": @"RUSSIA",
        @"468": @"RUSSIA",
        @"469": @"RUSSIA",
        
        @"471": @"TAIWAN",
        @"474": @"ESTONIA",
        @"475": @"LATVIA",
        @"477": @"LITHUANIA",
        @"479": @"SRI LANKA",
        @"480": @"PHILIPPINES",
        @"482": @"UKRAINE",
        @"484": @"MOLDOVA",
        @"485": @"ARMENIA",
        @"486": @"GEORGIA",
        @"487": @"KAZAKHSTAN",
        @"489": @"HONG KONG",
        
        @"520": @"GREECE",
        @"528": @"LEBANON",
        @"529": @"CYPRUS",
        @"531": @"MACEDONIA",
        @"535": @"MALTA",
        @"539": @"IRELAND",
        @"560": @"PORTUGAL",
        @"569": @"ICELAND",
        @"590": @"POLAND",
        @"594": @"ROMANIA",
        @"599": @"HUNGARY",
        
        @"600": @"SOUTH AFRICA",
        @"601": @"SOUTH AFRICA",
        @"609": @"MAURITIUS",
        @"611": @"MOROCCO",
        @"613": @"ALGERIA",
        @"619": @"TUNISIA",
        @"622": @"EGYPT",
        @"625": @"JORDAN",
        @"626": @"IRAN",
        @"627": @"KUWAIT",
        @"628": @"SAUDI ARABIA",
        @"629": @"EMIRATES",
        @"690": @"CHINA",
        @"691": @"CHINA",
        @"692": @"CHINA",
        @"693": @"CHINA",
        @"694": @"CHINA",
        @"695": @"CHINA",
        
        @"729": @"ISRAEL",
        @"740": @"GUATEMALA",
        @"741": @"EL SALVADOR",
        @"742": @"HONDURAS",
        @"743": @"NICARAGUA",
        @"744": @"COSTA RICA",
        @"746": @"DOMINICAN REPUBLIC",
        @"750": @"MEXICO",
        @"759": @"VENEZUELA",
        @"770": @"COLOMBIA",
        @"773": @"URUGUAY",
        @"775": @"PERU",
        @"777": @"BOLIVIA",
        @"779": @"ARGENTINA",
        @"780": @"CHILE",
        @"784": @"PARAGUAY",
        @"785": @"PERU",
        @"786": @"ECUADOR",
        @"789": @"BRAZIL",
        
        @"850": @"CUBA",
        @"858": @"SLOVAKIA",
        @"859": @"CZECH REPUBLIC",
        @"860": @"YUGLOSLAVIA",
        @"867": @"NORTH KOREA",
        @"869": @"TURKEY",
        @"880": @"SOUTH KOREA",
        @"885": @"THAILAND",
        @"888": @"SINGAPORE",
        @"890": @"INDIA",
        @"893": @"VIETNAM",
        @"899": @"INDONESIA",
        
        @"955": @"MALAYSIA",
        @"958": @"MACAU",
        @"977": @"INTERNATIONAL STANDARD SERIAL NUMBER FOR PERIODICALS (ISSN)",
        @"978": @"INTERNATIONAL STANDARD BOOK NUMBERING (ISBN)",
        @"979": @"INTERNATIONAL STANDARD MUSIC NUMBER (ISMN)",
        @"980": @"REFUND RECEIPTS",
        @"981": @"COMMON CURRENCY COUPONS",
        @"982": @"COMMON CURRENCY COUPONS",
        };
    }
    return countryCodesMap;
}

@end

