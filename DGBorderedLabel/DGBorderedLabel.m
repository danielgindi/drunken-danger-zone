//
//  DGBorderedLabel.m
//  DGBorderedLabel
//
//  Created by Daniel Cohen Gindi on 3/10/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
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
