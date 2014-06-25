//
//  DGBorderedLabelLayer.m
//  DGBorderedLabel
//
//  Created by Daniel Cohen Gindi on 3/10/13.
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

#import "DGBorderedLabelLayer.h"

@implementation DGBorderedLabelLayer

@dynamic font, textColor, textOutlineWidth, textOutlineColor;

- (void)_DGBorderedLabelLayer_initialize
{
    self.text = @"";
    self.textAlignment = NSTextAlignmentLeft;
    self.lineBreakMode = NSLineBreakByTruncatingTail;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self _DGBorderedLabelLayer_initialize];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self _DGBorderedLabelLayer_initialize];
    }
    return self;
}

- (id)initWithLayer:(DGBorderedLabelLayer*)layer
{
    self = [super initWithLayer:layer];
    if (self)
    {
        self->_text = layer->_text;
        self->_textAlignment = layer->_textAlignment;
        self->_lineBreakMode = layer->_lineBreakMode;
        self.font = layer.font;
        self.textColor = layer.textColor;
        self.textOutlineColor = layer.textOutlineColor;
    }
    return self;
}

- (void)setText:(NSString *)text
{
    _text = text;
    [self setNeedsDisplay];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    _textAlignment = textAlignment;
    [self setNeedsDisplay];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode
{
    _lineBreakMode = lineBreakMode;
    [self setNeedsDisplay];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize fitSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = self.lineBreakMode;
    
    NSDictionary *boundingRectAttributes = @{NSFontAttributeName: self.font,
                                             NSParagraphStyleAttributeName: paragraphStyle};
    
    fitSize = [self.text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:boundingRectAttributes context:nil].size;
#else
    fitSize = [self.text sizeWithFont:self.font constrainedToSize:size lineBreakMode:self.lineBreakMode];
#endif
    
    if (self.text.length)
    {
        fitSize.width += self.textOutlineWidth * 2.f;
        fitSize.height += self.textOutlineWidth * 2.f;
        if (fitSize.width > size.width && size.width > 0.f) fitSize.width = size.width;
        if (fitSize.height > size.height && size.height > 0.f) fitSize.height = size.height;
    }
    
    return fitSize;
}

+ (id)defaultValueForKey:(NSString *)key
{
    if ([key isEqualToString:@"font"])
    {
        return [UIFont systemFontOfSize:UIFont.systemFontSize];
    }
    else if ([key isEqualToString:@"textColor"])
    {
        return UIColor.darkTextColor;
    }
    else if ([key isEqualToString:@"textOutlineWidth"])
    {
        return @(1.f);
    }
    else if ([key isEqualToString:@"textOutlineColor"])
    {
        return UIColor.lightTextColor;
    }
    return [super defaultValueForKey:key];
}

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:@"font"])
    {
        return YES;
    }
    else if ([key isEqualToString:@"textColor"])
    {
        return YES;
    }
    else if ([key isEqualToString:@"textOutlineWidth"])
    {
        return YES;
    }
    else if ([key isEqualToString:@"textOutlineColor"])
    {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)ctx
{
    UIFont *font = self.font;
    UIColor *textOutlineColor = self.textOutlineColor;
    UIColor *textColor = self.textColor;
    NSString *text = self.text;
    
    UIGraphicsPushContext(ctx);
    CGContextSetAllowsAntialiasing(ctx, YES);
    CGContextSetShouldAntialias(ctx, YES);
    CGContextSetShouldSmoothFonts(ctx, YES);
    if (textOutlineColor)
    {
        CGContextSetTextDrawingMode(ctx, kCGTextStroke);
        CGContextSetFillColorWithColor(ctx, textOutlineColor.CGColor);
        CGContextSetLineWidth(ctx, self.textOutlineWidth);
        CGContextSetLineJoin(ctx, kCGLineJoinRound);
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = self.lineBreakMode;
        paragraphStyle.alignment = self.textAlignment;
        [text drawInRect:self.bounds withAttributes:@{NSFontAttributeName: font,
                                                           NSParagraphStyleAttributeName: paragraphStyle}];
#else
        [text drawInRect:self.bounds withFont:font lineBreakMode:self.lineBreakMode alignment:self.textAlignment];
#endif
    }
    if (textColor)
    {
        CGContextSetTextDrawingMode(ctx, kCGTextFill);
        CGContextSetFillColorWithColor(ctx, textColor.CGColor);
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = self.lineBreakMode;
        paragraphStyle.alignment = self.textAlignment;
        [text drawInRect:self.bounds withAttributes:@{NSFontAttributeName: font,
                                                      NSParagraphStyleAttributeName: paragraphStyle}];
#else
        [text drawInRect:self.bounds withFont:font lineBreakMode:self.lineBreakMode alignment:self.textAlignment];
#endif
    }
    UIGraphicsPopContext();
}

@end
