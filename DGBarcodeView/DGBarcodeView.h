//
//  DGBarcodeView.h
//  DGBarcodeView
//
//  Created by Daniel Cohen Gindi on 1/31/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import <UIKit/UIKit.h>
#import "DGBarcodeEncoder.h"

@interface DGBarcodeView : UIView

@property (nonatomic, strong) NSString *value;
@property (nonatomic, assign) DGBarcodeEncoding encoding;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGFloat spacingMultiplier;

@end
