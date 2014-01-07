//
//  DGBarcodeEncoder.h
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
