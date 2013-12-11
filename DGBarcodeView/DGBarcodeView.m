//
//  DGBarcodeView.m
//  DGBarcodeView
//
//  Created by Daniel Cohen Gindi on 1/31/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
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
