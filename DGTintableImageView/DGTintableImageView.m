//
//  TintableImageView.m
//  TintableImageView
//
//  Created by Daniel Cohen Gindi on 5/2/12.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGTintableImageView.h"

@implementation DGTintableImageView

- (void)drawRect:(CGRect)rect 
{
    if (_image && _color)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // draw original image
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        CGContextDrawImage(context, rect, _image.CGImage);
        
        // tint image (loosing alpha) - the luminosity of the original image is preserved
        CGContextSetBlendMode(context, kCGBlendModeColor);
        [_color setFill];
        CGContextFillRect(context, rect);
        
        // mask by alpha values of original image
        CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
        CGContextDrawImage(context, rect, _image.CGImage);
    }
    else
    {
        [super drawRect:rect];
    }
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    [self setNeedsDisplay];
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    [self setNeedsDisplay];
}

@end
