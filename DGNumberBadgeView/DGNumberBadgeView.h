//
//  DGNumberBadgeView.h
//  DGNumberBadgeView
//
//  Created by Daniel Cohen Gindi on 4/18/12.
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

#import <UIKit/UIKit.h>

typedef enum _DGNumberBadgeViewAnchor
{
    DGNumberBadgeViewAnchorTopLeft,
    DGNumberBadgeViewAnchorTop,
    DGNumberBadgeViewAnchorTopRight,
    DGNumberBadgeViewAnchorCenterLeft,
    DGNumberBadgeViewAnchorCenter,
    DGNumberBadgeViewAnchorCenterRight,
    DGNumberBadgeViewAnchorBottomLeft,
    DGNumberBadgeViewAnchorBottom,
    DGNumberBadgeViewAnchorBottomRight
} DGNumberBadgeViewAnchor;

@interface DGNumberBadgeView : UIView <UIAppearance>

@property (nonatomic, strong) UIView *attachedToView;
@property (nonatomic, assign) DGNumberBadgeViewAnchor anchor;
@property (nonatomic, assign) DGNumberBadgeViewAnchor innerAnchor;
@property (nonatomic, assign) CGSize anchorOffset;

@property (nonatomic, assign) NSUInteger value UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) BOOL shadow UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGSize shadowOffset UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat shadowBlurSize UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *shadowColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) BOOL shine UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *font UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *fillColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *strokeColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat strokeWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *textColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSTextAlignment alignment UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSUInteger pad UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) BOOL hideWhenZero UI_APPEARANCE_SELECTOR;

+ (DGNumberBadgeView *)badgeForView:(UIView *)view;

@end