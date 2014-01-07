//
//  DGBorderedLabel.m
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

#import "DGBorderedLabel.h"
#import "DGBorderedLabelLayer.h"

@interface DGBorderedLabel ()

@property (nonatomic, strong, readonly) DGBorderedLabelLayer *layer;

@end

@implementation DGBorderedLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.layer.contentsScale = UIScreen.mainScreen.scale;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.layer.contentsScale = UIScreen.mainScreen.scale;
    }
    return self;
}

#pragma mark - Custom layer

+ (Class)layerClass
{
    return [DGBorderedLabelLayer class];
}

#pragma mark - Properties

- (void)setText:(NSString *)text
{
    self.layer.text = text;
}

- (NSString *)text
{
    return self.layer.text;
}

- (void)setFont:(UIFont *)font
{
    self.layer.font = font;
}

- (UIFont*)font
{
    return self.layer.font;
}

- (void)setTextOutlineWidth:(CGFloat)textOutlineWidth
{
    self.layer.textOutlineWidth = textOutlineWidth;
}

- (CGFloat)textOutlineWidth
{
    return self.layer.textOutlineWidth;
}

- (void)setTextColor:(UIColor *)textColor
{
    self.layer.textColor = textColor;
}

- (UIColor*)textColor
{
    return self.layer.textColor;
}

- (void)setTextOutlineColor:(UIColor *)textOutlineColor
{
    self.layer.textOutlineColor = textOutlineColor;
}

- (UIColor*)textOutlineColor
{
    return self.layer.textOutlineColor;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    self.layer.textAlignment = textAlignment;
}

- (NSTextAlignment)textAlignment
{
    return self.layer.textAlignment;
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode
{
    self.layer.lineBreakMode = lineBreakMode;
}

- (NSLineBreakMode)lineBreakMode
{
    return self.layer.lineBreakMode;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return [self.layer sizeThatFits:size];
}

@end
