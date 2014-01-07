//
//  DGBarcodeView.m
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

#import "DGBarcodeView.h"
#import "DGBarcodeLayer.h"

@interface DGBarcodeView ()

@property (nonatomic, strong, readonly) DGBarcodeLayer *layer;

@end

@implementation DGBarcodeView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.spacingMultiplier = 1.f;
        self.color = [UIColor blackColor];
        self.encoding = DGBarcodeEncodingUPCA;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.layer.spacingMultiplier = 1.f;
        self.color = [UIColor blackColor];
        self.encoding = DGBarcodeEncodingUPCA;
    }
    return self;
}

#pragma mark - Custom layer

+ (Class)layerClass
{
    return [DGBarcodeLayer class];
}

#pragma mark - Properties

- (void)setValue:(NSString *)value
{
    self.layer.value = value;
}

- (NSString *)value
{
    return self.layer.value;
}

- (void)setEncoding:(DGBarcodeEncoding)encoding
{
    self.layer.encoding = encoding;
}

- (DGBarcodeEncoding)encoding
{
    return self.layer.encoding;
}

- (void)setColor:(UIColor *)color
{
    self.layer.color = color;
}

- (UIColor *)color
{
    return self.layer.color;
}

- (void)setSpacingMultiplier:(CGFloat)spacingMultiplier
{
    self.layer.spacingMultiplier = spacingMultiplier;
}

- (CGFloat)spacingMultiplier
{
    return self.layer.spacingMultiplier;
}

#pragma mark - UIView

- (CGSize)sizeThatFits:(CGSize)size
{
    return [self.layer sizeThatFits:size];
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
    [super setContentMode:contentMode];
    self.layer.contentMode = contentMode;
}

@end
