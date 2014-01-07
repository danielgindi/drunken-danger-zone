//
//  DGTextFieldPickerCellView.m
//  DGTextFieldPicker
//
//  Created by Daniel Cohen Gindi on 4/18/12.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
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

#import "DGTextFieldPickerCellView.h"

@interface DGTextFieldPickerCellView ()
{
    UILabel *_labelView;
}

- (CGGradientRef)newGradientWithColors:(NSArray *)colors locations:(CGFloat *)locations;

- (CGGradientRef)newGradientWithColors:(NSArray *)colors;

- (void)addRoundedRectPathToContext:(CGContextRef)context
                           withFrame:(CGRect)rect;

- (void)drawBorderInContext:(CGContextRef)context
                   withFrame:(CGRect)rect
                   withColor:(UIColor *)color
                    andWidth:(CGFloat)width
                    newFrame:(CGRect *)newFrame;

- (void)drawGradientBorderInContext:(CGContextRef)context
                          withFrame:(CGRect)rect
                          andColor1:(UIColor *)color1
                          andColor2:(UIColor *)color2
                           andWidth:(CGFloat)width
                           newFrame:(CGRect *)newFrame;

@end

@implementation DGTextFieldPickerCellView

static const CGFloat kPaddingX = 8;
static const CGFloat kPaddingY = 3;
static const CGFloat kMaxWidth = 250;

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f \
alpha:(a)]

#define HSVCOLOR(h,s,v) [UIColor colorWithHue:(h) saturation:(s) value:(v) alpha:1]
#define HSVACOLOR(h,s,v,a) [UIColor colorWithHue:(h) saturation:(s) value:(v) alpha:(a)]

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
    {
        self.contentMode = UIViewContentModeRedraw;
        
        _bgColor1 = RGBCOLOR(221, 231, 248);
        _bgColor2 = RGBCOLOR(188, 206, 241);
        _borderColor1 = RGBCOLOR(161, 187, 283);
        _borderColor2 = RGBCOLOR(118, 130, 214);
        
        _highlightedBgColor1 = RGBCOLOR(79, 144, 255);
        _highlightedBgColor2 = RGBCOLOR(49, 90, 255);
        _highlightedBorderColor1 = RGBCOLOR(53, 94, 255);
        _highlightedBorderColor2 = RGBCOLOR(53, 94, 255);
        
        _labelView = [[UILabel alloc] init];
        _labelView.backgroundColor = [UIColor clearColor];
        _labelView.textColor = [UIColor blackColor];
        _labelView.highlightedTextColor = [UIColor whiteColor];
        _labelView.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_labelView];
        
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

-(void)drawRect:(CGRect)rect 
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    if (self.selected)
    {
        CGRect frame = self.bounds, contentFrame = CGRectInset(frame, 1, 1);
        
        CGContextSaveGState(ctx);
        [self addRoundedRectPathToContext:ctx withFrame:contentFrame];        
        CGContextClip(ctx);
        
        CGGradientRef gradient = [self newGradientWithColors:[NSMutableArray arrayWithObjects:_highlightedBgColor1, _highlightedBgColor2, nil]];
        CGContextDrawLinearGradient(ctx, gradient, CGPointMake(contentFrame.origin.x, contentFrame.origin.y),
                                    CGPointMake(contentFrame.origin.x, contentFrame.origin.y+contentFrame.size.height),
                                    kCGGradientDrawsAfterEndLocation);
        CGGradientRelease(gradient);
        
        CGContextRestoreGState(ctx);
        
        if ([_highlightedBorderColor1 isEqual:_highlightedBorderColor2])
        {
            [self drawBorderInContext:ctx withFrame:frame withColor:_highlightedBorderColor1 andWidth:1.0f newFrame:nil];
        }
        else
        {
            [self drawGradientBorderInContext:ctx withFrame:frame andColor1:_highlightedBorderColor1 andColor2:_highlightedBorderColor2 andWidth:1.0f newFrame:nil];
        }
    }
    else 
    {
        CGRect frame = self.bounds, contentFrame = CGRectInset(frame, 1, 1);
        
        CGContextSaveGState(ctx);
        [self addRoundedRectPathToContext:ctx withFrame:contentFrame];        
        CGContextClip(ctx);
        
        CGGradientRef gradient = [self newGradientWithColors:[NSMutableArray arrayWithObjects:_bgColor1, _bgColor2, nil]];
        CGContextDrawLinearGradient(ctx, gradient, CGPointMake(contentFrame.origin.x, contentFrame.origin.y),
                                    CGPointMake(contentFrame.origin.x, contentFrame.origin.y+contentFrame.size.height),
                                    kCGGradientDrawsAfterEndLocation);
        CGGradientRelease(gradient);
        
        CGContextRestoreGState(ctx);
        
        if ([_borderColor1 isEqual:_borderColor2])
        {
            [self drawBorderInContext:ctx withFrame:frame withColor:_borderColor1 andWidth:1.0f newFrame:nil];
        }
        else
        {
            [self drawGradientBorderInContext:ctx withFrame:frame andColor1:_borderColor1 andColor2:_borderColor2 andWidth:1.0f newFrame:nil];
        }
    }
}

- (void)layoutSubviews 
{
    _labelView.frame = CGRectMake(kPaddingX, kPaddingY,
                                  self.frame.size.width-kPaddingX *2, self.frame.size.height-kPaddingY *2);
}

- (CGSize)sizeThatFits:(CGSize)size 
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
    CGSize labelSize = [_labelView.text sizeWithAttributes:@{NSFontAttributeName: _labelView.font}];
#else
    CGSize labelSize = [_labelView.text sizeWithFont:_labelView.font];
#endif
    CGFloat width = labelSize.width + kPaddingX *2;
    if (labelSize.height + kPaddingY *2 > width) width = labelSize.height + kPaddingY *2;
    return CGSizeMake(width > kMaxWidth ? kMaxWidth : width, labelSize.height + kPaddingY *2);
}

- (NSString *)label 
{
    return _labelView.text;
}

- (void)setLabel:(NSString *)label 
{
    _labelView.text = label;
}

- (UIFont *)font 
{
    return _labelView.font;
}

- (void)setFont:(UIFont *)font 
{
    _labelView.font = font;
}

- (void)setSelected:(BOOL)selected 
{
    _selected = selected;
    
    _labelView.highlighted = selected;
    [self setNeedsDisplay];
}

- (UIColor *)textColor
{
    return _labelView.textColor;
}

- (void)setTextColor:(UIColor *)textColor
{
    _labelView.textColor = textColor;
}

- (UIColor *)highlightedTextColor
{
    return _labelView.highlightedTextColor;
}

- (void)setHighlightedTextColor:(UIColor *)highlightedTextColor
{
    _labelView.highlightedTextColor = highlightedTextColor;
}

- (void)setBgColor1:(UIColor *)bgColor1
{
    _bgColor1 = bgColor1;
    [self setNeedsDisplay];
}

- (void)setBgColor2:(UIColor *)bgColor2
{
    _bgColor2 = bgColor2;
    [self setNeedsDisplay];
}

- (void)setBorderColor1:(UIColor *)borderColor1
{
    _borderColor1 = borderColor1;
    [self setNeedsDisplay];
}

- (void) setBorderColor2:(UIColor *)borderColor2
{
    _borderColor2 = borderColor2;
    [self setNeedsDisplay];
}

- (void)setHighlightedBgColor1:(UIColor *)highlightedBgColor1
{
    _highlightedBgColor1 = highlightedBgColor1;
    [self setNeedsDisplay];
}

- (void)setHighlightedBgColor2:(UIColor *)highlightedBgColor2
{
    _highlightedBgColor2 = highlightedBgColor2;
    [self setNeedsDisplay];
}

- (void)setHighlightedBorderColor1:(UIColor *)highlightedBorderColor1
{
    _highlightedBorderColor1 = highlightedBorderColor1;
    [self setNeedsDisplay];
}

- (void)setHighlightedBorderColor2:(UIColor *)highlightedBorderColor2
{
    _highlightedBorderColor2 = highlightedBorderColor2;
    [self setNeedsDisplay];
}

#pragma mark - Drawing helpers

- (CGGradientRef)newGradientWithColors:(NSArray *)colors locations:(CGFloat *)locations
{
    NSMutableArray *colorsForGradient = [[NSMutableArray alloc] init];
    for (UIColor *color in colors)
    {
        [colorsForGradient addObject:(id)color.CGColor];
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef space = CGBitmapContextGetColorSpace(context);
    CGGradientRef gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)(colorsForGradient), locations);
    
    return gradient;
}

- (CGGradientRef)newGradientWithColors:(NSArray *)colors
{
    return [self newGradientWithColors:colors locations:nil];
}

- (void)addRoundedRectPathToContext:(CGContextRef)context
                           withFrame:(CGRect)rect
{
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextBeginPath(context);
    
    CGFloat fw = rect.size.width, fh = rect.size.height, halfHeight = fh / 2.0f, halfWidth = fw / 2.0f, radius = halfHeight;
    
    CGContextMoveToPoint(context, fw, floor(halfHeight));
    CGContextAddArcToPoint(context, fw, fh, floor(halfWidth), fh, radius);
    CGContextAddArcToPoint(context, 0, fh, 0, floor(halfHeight), radius);
    CGContextAddArcToPoint(context, 0, 0, floor(halfWidth), 0, radius);
    CGContextAddArcToPoint(context, fw, 0, fw, floor(halfHeight), radius);
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

- (void)drawBorderInContext:(CGContextRef)context
                   withFrame:(CGRect)rect
                   withColor:(UIColor *)color
                    andWidth:(CGFloat)width
                    newFrame:(CGRect *)newFrame
{
    if (color)
    {
        CGRect strokeRect = CGRectInset(rect, width/2.0f, width/2.0f);
        
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, CGRectGetMinX(strokeRect), CGRectGetMinY(strokeRect));
        CGContextBeginPath(context);
        
        CGContextSetLineWidth(context, width);
        [color setStroke];
        
        CGFloat fw = strokeRect.size.width, fh = strokeRect.size.height, radius = fh / 2.0f;
        
        CGContextMoveToPoint(context, 0, radius);
        CGContextAddArcToPoint(context, 0, 0, radius, 0, radius);  
        CGContextAddArcToPoint(context, fw, 0, fw, radius, radius);
        CGContextAddLineToPoint(context, fw, radius);
        CGContextAddArcToPoint(context, fw, fh, fw-radius, fh, radius);
        CGContextAddLineToPoint(context, fw-radius, fh);
        CGContextAddLineToPoint(context, radius, fh);
        CGContextAddArcToPoint(context, 0, fh, 0, fh-radius, radius);
        CGContextAddLineToPoint(context, 0, radius);
        
        CGContextStrokePath(context);
        
        CGContextRestoreGState(context);
    }
    if (newFrame)
    {
        *newFrame = CGRectMake(rect.origin.x + (color ? width : 0),
                               rect.origin.y + (color ? width : 0),
                               rect.size.width - ((color ? width *2.0f : 0)),
                               rect.size.height - ((color ? width *2.0f : 0)));
    }
}

- (void)drawGradientBorderInContext:(CGContextRef)context
                          withFrame:(CGRect)rect
                          andColor1:(UIColor *)color1
                          andColor2:(UIColor *)color2
                           andWidth:(CGFloat)width
                           newFrame:(CGRect *)newFrame
{
    CGContextSaveGState(context);
    
    CGRect strokeRect = CGRectInset(rect, width/2.0f, width/2.0f);
    
    [self addRoundedRectPathToContext:context withFrame:strokeRect];
    
    CGContextSetLineWidth(context, width);
    CGContextReplacePathWithStrokedPath(context);
    CGContextClip(context);
    
    CGFloat locations[] = {0.0f, 1.0f};
    CGGradientRef gradient = [self newGradientWithColors:[NSMutableArray arrayWithObjects:color1, color2, nil] locations:locations];
    CGContextDrawLinearGradient(context, gradient, CGPointMake(rect.origin.x, rect.origin.y),
                                CGPointMake(rect.origin.x, rect.origin.y+rect.size.height),
                                kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
    
    CGContextRestoreGState(context);
    
    if (newFrame)
    {
        *newFrame = CGRectInset(rect, width, width);
    }
}

@end
