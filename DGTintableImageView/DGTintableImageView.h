//
//  TintableImageView.h
//  TintableImageView
//
//  Created by Daniel Cohen Gindi on 5/2/12.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//
//  This UIView accepts a UIImage and a UIColor, displaying the UIImage tinted to the specified UIColor.
//

#import <UIKit/UIKit.h>

@interface DGTintableImageView : UIView

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIImage *image;

@end
