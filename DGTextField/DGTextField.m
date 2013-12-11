//
//  DGTextField.m
//  DGTextField
//
//  Created by Daniel Cohen Gindi on 10/19/12.
//  Copyright (c) 2012 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGTextField.h"

@interface DGTextField ()
{
    BOOL _bypassClearButtonRect;
}
@end

@implementation DGTextField

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

- (BOOL)isRtl
{
    return self.class.isRtl;
}

- (void)initialize_DGTextField
{
    self.textFieldUIDirection = UITextWritingDirectionNatural;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize_DGTextField];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize_DGTextField];
    }
    return self;
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    _contentInsets = contentInsets;
    [self setNeedsLayout];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderColor = placeholderColor;
    //[self setNeedsDisplay]; // this doesn't refresh placeholder color
    NSString *placeholder = self.placeholder;
    self.placeholder = @"";
    self.placeholder = placeholder;
}

- (void)setClearButtonInsets:(UIEdgeInsets)clearButtonInsets
{
    _clearButtonInsets = clearButtonInsets;
    [self setNeedsDisplay];
}

- (void)setTextFieldUIDirection:(UITextDirection)textFieldUIDirection
{
    _textFieldUIDirection = textFieldUIDirection;
    [self setNeedsDisplay];
}

#pragma mark - UITextField

- (void)drawPlaceholderInRect:(CGRect)rect
{
    if (_placeholderColor)
    {
        [_placeholderColor setFill];
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        paragraphStyle.alignment = self.textAlignment;
        [self.placeholder drawInRect:rect withAttributes:@{NSFontAttributeName: self.font,
                                                           NSParagraphStyleAttributeName: paragraphStyle}];
#elif __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
        [self.placeholder drawInRect:rect withFont:self.font lineBreakMode:NSLineBreakByTruncatingTail alignment:self.textAlignment];
#else
        [self.placeholder drawInRect:rect withFont:self.font lineBreakMode:UILineBreakModeTailTruncation alignment:self.textAlignment];
#endif
    }
    else
    {
        [super drawPlaceholderInRect:rect];
    }
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    if ((self.class.isRtl && _textFieldUIDirection == UITextWritingDirectionNatural)
        || _textFieldUIDirection == UITextWritingDirectionRightToLeft)
    {
        _bypassClearButtonRect = YES;
        CGRect rect = UIEdgeInsetsInsetRect([super textRectForBounds:bounds], _contentInsets);
        _bypassClearButtonRect = NO;
        rect.origin.x = bounds.origin.x + bounds.size.width - rect.size.width - (rect.origin.x - bounds.origin.x);
        return rect;
    }
    else
    {
        return UIEdgeInsetsInsetRect([super textRectForBounds:bounds], _contentInsets);
    }
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
	return [self textRectForBounds:bounds];
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
	CGRect rect = [super clearButtonRectForBounds:bounds];
    if (!_bypassClearButtonRect)
    {
        rect.origin.x += _clearButtonInsets.right - _clearButtonInsets.left;
        rect.origin.y += _clearButtonInsets.top - _clearButtonInsets.bottom;
        if ((self.class.isRtl && _textFieldUIDirection == UITextWritingDirectionNatural)
            || _textFieldUIDirection == UITextWritingDirectionRightToLeft)
        {
            rect.origin.x = bounds.origin.x + bounds.size.width - rect.size.width - (rect.origin.x - bounds.origin.x);
        }
    }
    return rect;
}

@end
