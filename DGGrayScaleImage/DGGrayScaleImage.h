//
//  DGGrayScaleImage.h
//  DGGrayScaleImage
//
//  Created by Daniel Cohen Gindi on 12/2/12.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import <UIKit/UIKit.h>

typedef enum _DGGrayScaleImageMode
{
    DGGrayScaleImageModeNatural,
    DGGrayScaleImageModeNaturalNTSC,
    DGGrayScaleImageModeAccurate
} DGGrayScaleImageMode;

@interface DGGrayScaleImage : UIImage

- (id)initWithImage:(UIImage *)image withMode:(DGGrayScaleImageMode)colorMode andAlphaMultiplier:(float)alphaMultiplier;
+ (id)grayScaleImageFromImage:(UIImage *)image withMode:(DGGrayScaleImageMode)colorMode andAlphaMultiplier:(float)alphaMultiplier;

@end
