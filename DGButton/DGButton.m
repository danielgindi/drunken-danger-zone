//
//  DGButton.m
//  DGButton
//
//  Created by Daniel Cohen Gindi on 1/24/13.
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

#import "DGButton.h"

@implementation DGButton

+ (BOOL)isRtl
{
    static BOOL isRtl = NO;
    static BOOL isRtlFound = NO;
    if (!isRtlFound)
    {
        isRtl = [NSLocale characterDirectionForLanguage:[NSBundle mainBundle].preferredLocalizations[0]] == NSLocaleLanguageDirectionRightToLeft;
        isRtlFound = YES;
    }
    return isRtl;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _respondsToRtl = YES;
        _imageOnOppositeDirection = NO;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _respondsToRtl = YES;
        _imageOnOppositeDirection = NO;
    }
    return self;
}

- (void)setImageOnOppositeDirection:(BOOL)imageOnOppositeDirection
{
    _imageOnOppositeDirection = imageOnOppositeDirection;
    [self setNeedsLayout];
}

- (void)setRespondsToRtl:(BOOL)respondsToRtl
{
    _respondsToRtl = respondsToRtl;
    [self setNeedsLayout];
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    if (_imageOnOppositeDirection != (_respondsToRtl && self.class.isRtl))
    {
        CGRect frame = [super imageRectForContentRect:contentRect];
        frame.origin.x = (contentRect.origin.x + contentRect.size.width) - frame.size.width - frame.origin.x;
        return frame;
    }
    else
    {
        return [super imageRectForContentRect:contentRect];
    }
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    if (_imageOnOppositeDirection != (_respondsToRtl && self.class.isRtl))
    {
        CGRect frame = [super titleRectForContentRect:contentRect];
        frame.origin.x = frame.origin.x - [self imageRectForContentRect:contentRect].size.width;
        return frame;
    }
    else
    {
        return [super titleRectForContentRect:contentRect];
    }
}

@end
