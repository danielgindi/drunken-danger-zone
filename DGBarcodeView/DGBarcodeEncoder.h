//
//  DGBarcodeEncoder.h
//  DGBarcodeView
//
//  Created by Daniel Cohen Gindi on 1/31/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import <Foundation/Foundation.h>

typedef enum _DGBarcodeEncoding
{
    DGBarcodeEncodingUPCA,
    DGBarcodeEncodingUPCE,
    DGBarcodeEncodingUPCSupplement2,
    DGBarcodeEncodingUPCSupplement5,
    DGBarcodeEncodingPostNet,
    DGBarcodeEncodingStandard2of5,
    DGBarcodeEncodingInterleaved2of5,
    DGBarcodeEncodingISBN,
    DGBarcodeEncodingITF14,
    DGBarcodeEncodingJAN13,
    DGBarcodeEncodingFIM,
    DGBarcodeEncodingEAN8,
    DGBarcodeEncodingEAN13,
    DGBarcodeEncodingCode11,
    DGBarcodeEncodingCode39,
    DGBarcodeEncodingCode39Extended,
    DGBarcodeEncodingUCC12,
    DGBarcodeEncodingUCC13,
    DGBarcodeEncodingIndustrial2of5,
    DGBarcodeEncodingBOOKLAND,
    DGBarcodeEncodingUSD8
} DGBarcodeEncoding;

@interface DGBarcodeEncoder : NSObject

+ (DGBarcodeEncoder *)encoderForEncoding:(DGBarcodeEncoding)encoding;
+ (NSString *)encodedValueWithValue:(NSString *)value inEncoding:(DGBarcodeEncoding)encoding;
- (NSString *)encodedValueWithValue:(NSString *)value;
- (NSString *)encodedValueWithValue:(NSString *)value country:(out NSString **)country;

- (BOOL)isNumeric:(NSString *)value;
- (BOOL)isNumericAndDashes:(NSString *)value;
- (NSDictionary *)countryCodesMap;

@end
