//
//  DGBarcodeLayer.h
//  DGBarcodeView
//
//  Created by Daniel Cohen Gindi on 2/1/13.
//  Copyright (c) 2013 AnyGym. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import <QuartzCore/QuartzCore.h>
#import "DGBarcodeEncoder.h"

@interface DGBarcodeLayer : CALayer

@property (nonatomic, strong) NSString *value;
@property (nonatomic, assign) DGBarcodeEncoding encoding;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGFloat spacingMultiplier;
@property (nonatomic, assign) UIViewContentMode contentMode;

- (CGSize)sizeThatFits:(CGSize)size;

@end
