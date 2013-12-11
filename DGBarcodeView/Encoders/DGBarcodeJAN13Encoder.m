//
//  DGBarcodeJAN13Encoder.m
//  DGBarcodeView
//
//  Created by Daniel Cohen Gindi on 1/31/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGBarcodeJAN13Encoder.h"

@implementation DGBarcodeJAN13Encoder

- (NSString *)encodedValueWithValue:(NSString *)value
{
    if (![value hasPrefix:@"49"] || ![self isNumeric:value])
    {
#if (DEBUG)
        NSLog(@"DGBarcodeEncoder JAN13: Must start with 49, and may only contain digits");
#endif
        return nil;
    }
    
    return [super encodedValueWithValue:value];
}

@end
