//
//  DGBorderedLabelLayer.h
//  DGBorderedLabel
//
//  Created by Daniel Cohen Gindi on 3/10/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import <QuartzCore/QuartzCore.h>

@interface DGBorderedLabelLayer : CALayer

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) CGFloat textOutlineWidth;
@property (nonatomic, strong) UIColor *textColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *textOutlineColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSTextAlignment textAlignment UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSLineBreakMode lineBreakMode UI_APPEARANCE_SELECTOR;

- (CGSize)sizeThatFits:(CGSize)size;

@end