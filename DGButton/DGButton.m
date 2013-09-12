//
//  DGButton.m
//  DGButton
//
//  Created by Daniel Cohen Gindi on 1/24/13.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
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
