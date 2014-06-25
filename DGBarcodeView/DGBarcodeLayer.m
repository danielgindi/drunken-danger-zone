//
//  DGBarcodeLayer.m
//  DGBarcodeView
//
//  Created by Daniel Cohen Gindi on 2/1/13.
//  Copyright (c) 2013 AnyGym. All rights reserved.
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

#import "DGBarcodeLayer.h"

@interface DGBarcodeLayer ()
{
    NSString *encodedValue;
}
@end

@implementation DGBarcodeLayer

@dynamic spacingMultiplier;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.spacingMultiplier = 1.f;
        self.color = [UIColor blackColor];
        self.encoding = DGBarcodeEncodingUPCA;
        self.contentMode = UIViewContentModeCenter;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.spacingMultiplier = 1.f;
        self.color = [UIColor blackColor];
        self.encoding = DGBarcodeEncodingUPCA;
        self.contentMode = UIViewContentModeCenter;
    }
    return self;
}

- (id)initWithLayer:(DGBarcodeLayer*)layer
{
    self = [super initWithLayer:layer];
    if (self)
    {
        self.spacingMultiplier = layer.spacingMultiplier;
        self->_color = layer->_color;
        self->_encoding = layer->_encoding;
        self->encodedValue = layer->encodedValue;
        self->_contentMode = layer->_contentMode;
    }
    return self;
}

#pragma mark - Properties

- (void)setValue:(NSString *)value
{
    _value = value;
    encodedValue = _value != nil ? [DGBarcodeEncoder encodedValueWithValue:_value inEncoding:_encoding] : nil;
    [self setNeedsDisplay];
}

- (void)setEncoding:(DGBarcodeEncoding)encoding
{
    _encoding = encoding;
    encodedValue = _value != nil ? [DGBarcodeEncoder encodedValueWithValue:_value inEncoding:_encoding] : nil;
    [self setNeedsDisplay];
}

- (void)setColor:(UIColor *)color
{
    if (!color)
    {
        color = [UIColor blackColor];
    }
    _color = color;
    [self setNeedsDisplay];
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
    _contentMode = contentMode;
    [self setNeedsDisplay];
}

#pragma mark - Helpers

- (CGSize)sizeThatFits:(CGSize)size
{
    NSInteger length = encodedValue.length;
    
    if (!length) return size;
    
    CGFloat width = size.width;
    CGFloat fLength = (CGFloat)length;
    
    if (_encoding == DGBarcodeEncodingITF14)
    {
        CGFloat bearerWidth = (CGFloat)(int)((width / 12.f));
        CGFloat quiteZone = (CGFloat)(int)(width * 0.05f);
        CGFloat barWidth = (CGFloat)(int)((width - bearerWidth * 2.f - quiteZone * 2.f) / fLength);
        
        size.width = (CGFloat)(barWidth * fLength + bearerWidth * 2.f + quiteZone * 2.f);
    }
    else
    {
        CGFloat barWidthModifier = 1.f;
        if (_encoding == DGBarcodeEncodingPostNet)
        {
            barWidthModifier = 2.f;
        }
        
        CGFloat barWidth = (CGFloat)(int)((width / barWidthModifier) / fLength) * barWidthModifier;
        
        size.width = (CGFloat)(barWidth * fLength);
    }
    return size;
}

#pragma mark - Animation

+ (id)defaultValueForKey:(NSString *)key
{
    if ([key isEqualToString:@"spacingMultiplier"])
    {
        return @(1.f);
    }
    return [super defaultValueForKey:key];
}

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:@"spacingMultiplier"])
    {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

#pragma mark - Drawing

- (void)drawInContext:(CGContextRef)ctx
{
    NSInteger length = encodedValue.length;
    
    if (!length) return;
    
    CGRect rect = self.bounds;
    
    CGFloat x = rect.origin.x, y = rect.origin.y;
    CGFloat width = rect.size.width, height = rect.size.height, y2 = y + height;
    CGFloat fLength = (CGFloat)length;
    
    if (_encoding == DGBarcodeEncodingITF14)
    {
        CGFloat bearerWidth = (CGFloat)(int)((width / 12.05f));
        CGFloat quiteZone = (CGFloat)(int)(width * 0.05f);
        CGFloat availableWidth = width - bearerWidth * 2.f + quiteZone * 2.f;
        CGFloat barWidth = (CGFloat)(availableWidth / fLength);
        CGFloat xOffset = x + bearerWidth + quiteZone;
        
        if (barWidth <= 0 || quiteZone <= 0)
        {
            return;
        }
        
        if (self.contentMode != UIViewContentModeScaleToFill &&
            self.contentMode != UIViewContentModeScaleAspectFit &&
            self.contentMode != UIViewContentModeScaleAspectFill)
        {
            barWidth = (CGFloat)(int)barWidth;
            xOffset += (CGFloat)(int)((availableWidth - barWidth * fLength) / 2.f);
        }
        
        xOffset += (fLength * barWidth - fLength * barWidth * self.spacingMultiplier) / 2.f;
        
        CGContextSetStrokeColorWithColor(ctx, _color.CGColor);
        CGContextSetLineWidth(ctx, barWidth);
        
        unichar * encoded = malloc(sizeof(unichar) * (length + 1));
        [encodedValue getCharacters:encoded];
        
        barWidth *= self.spacingMultiplier;
        
        CGFloat xx;
        for (int j = 0; j < length; j++)
        {
            if (encoded[j] == L'1')
            {
                xx = xOffset + j * barWidth;
                CGContextMoveToPoint(ctx, xx, y);
                CGContextAddLineToPoint(ctx, xx, y2);
            }
        }
        CGContextStrokePath(ctx);
        
        CGContextSetLineWidth(ctx, rect.size.height / 8.f);
        
        CGContextMoveToPoint(ctx, x, y);
        CGContextAddLineToPoint(ctx, x + width, y);
        CGContextMoveToPoint(ctx, x, y2);
        CGContextAddLineToPoint(ctx, x + width, y2);
        CGContextMoveToPoint(ctx, x, y);
        CGContextAddLineToPoint(ctx, x, y2);
        CGContextMoveToPoint(ctx, x + width, y);
        CGContextAddLineToPoint(ctx, x + width, y2);
        
        CGContextStrokePath(ctx);
        
        free(encoded);
    }
    else
    {
        CGFloat barWidthModifier = 1.f;
        if (_encoding == DGBarcodeEncodingPostNet)
        {
            barWidthModifier = 2.f;
        }
        
        CGFloat barWidth = ((width / barWidthModifier) / fLength) * barWidthModifier;
        if (self.contentMode != UIViewContentModeScaleToFill &&
            self.contentMode != UIViewContentModeScaleAspectFit &&
            self.contentMode != UIViewContentModeScaleAspectFill)
        {
            barWidth = (CGFloat)(int)barWidth;
        }
        
        CGFloat xOffset = 0.f;
        
        if (barWidth <= 0.f)
        {
            return;
        }
        
        CGFloat realBarWidth = barWidth / barWidthModifier;
        
        switch (self.contentMode)
        {
            case UIViewContentModeScaleToFill:
            case UIViewContentModeScaleAspectFit:
            case UIViewContentModeScaleAspectFill:
            case UIViewContentModeLeft:
            case UIViewContentModeBottomLeft:
            case UIViewContentModeTopLeft:
                xOffset = 0.f;
                break;
            default:
            case UIViewContentModeCenter:
            case UIViewContentModeBottom:
            case UIViewContentModeTop:
                xOffset = (CGFloat)(int)((width - barWidth * fLength) / 2.f);
                break;
            case UIViewContentModeRight:
            case UIViewContentModeBottomRight:
            case UIViewContentModeTopRight:
                xOffset = (CGFloat)(int)(width - barWidth * fLength);
                break;
        }
        
        xOffset += x;
        
        xOffset += (fLength * barWidth - fLength * barWidth * self.spacingMultiplier) / 2.f;
        
        CGContextSetStrokeColorWithColor(ctx, _color.CGColor);
        CGContextSetLineWidth(ctx, realBarWidth);
        
        unichar * encoded = malloc(sizeof(unichar) * (length + 1));
        [encodedValue getCharacters:encoded];
        
        barWidth *= self.spacingMultiplier;
        realBarWidth *= self.spacingMultiplier;
        
        CGFloat xx;
        for (int j = 0; j < length; j++)
        {
            if (_encoding == DGBarcodeEncodingPostNet)
            {
                if (encoded[j] != L'1')
                {
                    CGContextSetStrokeColorWithColor(ctx, _color.CGColor);
                    xx = xOffset + j * barWidth + realBarWidth;
                    CGContextMoveToPoint(ctx, xx, y2);
                    CGContextAddLineToPoint(ctx, xx, height / 2.f);
                }
            }
            
            if (encoded[j] == L'1')
            {
                CGContextSetStrokeColorWithColor(ctx, _color.CGColor);
                xx = xOffset + j * barWidth + barWidth * 0.5f;
                CGContextMoveToPoint(ctx, xx, y);
                CGContextAddLineToPoint(ctx, xx, y2);
            }
        }
        
        CGContextStrokePath(ctx);
        
        free(encoded);
    }
}

@end
