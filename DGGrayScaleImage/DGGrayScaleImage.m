//
//  DGGrayScaleImage.m
//  DGGrayScaleImage
//
//  Created by Daniel Cohen Gindi on 12/2/12.
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

#import "DGGrayScaleImage.h"

#define RED_LUMINOSITY_NTSC     0.299
#define GREEN_LUMINOSITY_NTSC   0.587
#define BLUE_LUMINOSITY_NTSC    0.114

#define RED_LUMINOSITY      0.3086
#define GREEN_LUMINOSITY    0.6094
#define BLUE_LUMINOSITY     0.0820

#define CHANNEL_ALPHA   0
#define CHANNEL_BLUE    1
#define CHANNEL_GREEN   2
#define CHANNEL_RED     3

@implementation DGGrayScaleImage

- (id)initWithImage:(UIImage *)image withMode:(DGGrayScaleImageMode)colorMode andAlphaMultiplier:(float)alphaMultiplier
{
	CGSize size = image.size;
	
	int width = size.width;
	int height = size.height;
	
	uint32_t *pixels = (uint32_t *)malloc(width *height *sizeof(uint32_t));
	
	memset(pixels, 0, width *height *sizeof(uint32_t));
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	CGContextRef context = CGBitmapContextCreate(pixels,
												 width, height, 8,
												 width *sizeof(uint32_t),
												 colorSpace,
												 kCGBitmapByteOrder32Little |
												 kCGImageAlphaPremultipliedLast);
	
	CGContextDrawImage(context, CGRectMake(0, 0, width, height), image.CGImage);
	
	uint8_t *rgbaPixel;
	uint32_t value;
	BOOL hasAlpha = alphaMultiplier != 1.0f;
	BOOL alphaCheckBoundary = alphaMultiplier > 1.0f;
	
	switch (colorMode)
	{
		default:
		case DGGrayScaleImageModeNatural:
		case DGGrayScaleImageModeNaturalNTSC:
		{
			float redMultiplier, greenMultiplier, blueMultiplier;
			if (colorMode == DGGrayScaleImageModeNaturalNTSC)
			{
				redMultiplier = RED_LUMINOSITY_NTSC;
				greenMultiplier = GREEN_LUMINOSITY_NTSC;
				blueMultiplier = BLUE_LUMINOSITY_NTSC;
			}
			else
			{
				redMultiplier = RED_LUMINOSITY;
				greenMultiplier = GREEN_LUMINOSITY;
				blueMultiplier = BLUE_LUMINOSITY;
			}
			
			for(int y = 0, x; y < height; y++)
			{
				for(x = 0; x < width; x++)
				{
					rgbaPixel = (uint8_t *) &pixels[y *width + x];
					
					value = redMultiplier *rgbaPixel[CHANNEL_RED] + greenMultiplier *rgbaPixel[CHANNEL_GREEN] + blueMultiplier *rgbaPixel[CHANNEL_BLUE];
					
					rgbaPixel[CHANNEL_RED] = value;
					rgbaPixel[CHANNEL_GREEN] = value;
					rgbaPixel[CHANNEL_BLUE] = value;
					
					if (hasAlpha)
					{
						if (alphaCheckBoundary)
						{
							value = rgbaPixel[CHANNEL_ALPHA] *alphaMultiplier;
							if (value > 255) value = 255;
							rgbaPixel[CHANNEL_ALPHA] = value;
						}
						else
						{
							rgbaPixel[CHANNEL_ALPHA] = rgbaPixel[CHANNEL_ALPHA] *alphaMultiplier;
						}
					}
				}
			}
		}
			break;
		case DGGrayScaleImageModeAccurate:
		{
			for(int y = 0, x; y < height; y++)
			{
				for(x = 0; x < width; x++)
				{
					rgbaPixel = (uint8_t *) &pixels[y *width + x];
					
					value = ((uint32_t)rgbaPixel[CHANNEL_RED] + (uint32_t)rgbaPixel[CHANNEL_GREEN] + (uint32_t)rgbaPixel[CHANNEL_BLUE]) / 3;
					
					rgbaPixel[CHANNEL_RED] = value;
					rgbaPixel[CHANNEL_GREEN] = value;
					rgbaPixel[CHANNEL_BLUE] = value;
					
					if (hasAlpha)
					{
						if (alphaCheckBoundary)
						{
							value = rgbaPixel[CHANNEL_ALPHA] *alphaMultiplier;
							if (value > 255) value = 255;
							rgbaPixel[CHANNEL_ALPHA] = value;
						}
						else
						{
							rgbaPixel[CHANNEL_ALPHA] = rgbaPixel[CHANNEL_ALPHA] *alphaMultiplier;
						}
					}
				}
			}
		}
			break;
	}
	
	CGImageRef cgImage = CGBitmapContextCreateImage(context);
	
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	free(pixels);
	
	self = [super initWithCGImage:cgImage scale:image.scale orientation:image.imageOrientation];
	CGImageRelease(cgImage);
	
	return self;
}

+ (id)grayScaleImageFromImage:(UIImage *)image withMode:(DGGrayScaleImageMode)colorMode andAlphaMultiplier:(float)alphaMultiplier
{
    if ([image isKindOfClass:self]) return (id)image;
    
	return [[DGGrayScaleImage alloc] initWithImage:image withMode:colorMode andAlphaMultiplier:alphaMultiplier];
}

@end
