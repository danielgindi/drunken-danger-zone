//
//  DGNumberBadgeView.h
//  DGNumberBadgeView
//
//  Created by Daniel Cohen Gindi on 4/18/12.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
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
@property (nonatomic, assign) UITextAlignment alignment UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSUInteger pad UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) BOOL hideWhenZero UI_APPEARANCE_SELECTOR;

+ (DGNumberBadgeView *)badgeForView:(UIView *)view;

@end