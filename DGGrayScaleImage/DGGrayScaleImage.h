//
//  DGGrayScaleImage.h
//
//  Created by Daniel Cohen Gindi on 12/2/12.
//

#import <UIKit/UIKit.h>

typedef enum _DGGrayScaleImageMode
{
    DGGrayScaleImageModeNatural,
    DGGrayScaleImageModeNaturalNTSC,
    DGGrayScaleImageModeAccurate
} DGGrayScaleImageMode;

@interface DGGrayScaleImage : UIImage

- (id)initWithImage:(UIImage*)image withMode:(DGGrayScaleImageMode)colorMode andAlphaMultiplier:(float)alphaMultiplier;
+ (id)grayScaleImageFromImage:(UIImage*)image withMode:(DGGrayScaleImageMode)colorMode andAlphaMultiplier:(float)alphaMultiplier;

@end
