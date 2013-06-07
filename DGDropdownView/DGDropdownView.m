//
//  DGDropdownView.m
//  DGDropdownView
//
//  Created by Daniel Cohen Gindi on 3/10/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGDropdownView.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

// For use with objc_getAssociatedObject/objc_setAssociatedObject to attach arrays of dropdown-views to parent views
#define ASSOCIATED_KEY @"DGDropdownView_array" 

@interface DGDropdownView ()
{
    CAGradientLayer *backgroundLayer;
    CALayer *bottomBorderLayer;
    UIImageView *imageView;
    UILabel *titleLabel, *detailLabel;
    id actionTarget;
    SEL actionSelector;
    NSTimeInterval intervalToHideAfter;
    BOOL showAnimated;
    UIView *showInView;
}

@end

@implementation DGDropdownView

- (void)initialize_DGDropdownView
{
    _backgroundColors = @[
                          [UIColor colorWithRed:184/255.f green:200/255.f blue:242/255.f alpha:1.f],
                          [UIColor colorWithRed:148/255.f green:173/255.f blue:242/255.f alpha:1.f]
                          ];
    _backgroundColorPositions = nil;
    _bottomBorderColor = nil;
    _bottomBorderWidth = 1.5f;
    
    _detailTextColor = _titleTextColor = [UIColor colorWithWhite:10/255.f alpha:1.f];
    _detailShadowColor = _titleShadowColor = [UIColor colorWithWhite:255/255.f alpha:1.f];
    _detailShadowOffset = _titleShadowOffset = CGSizeMake(0.f, 1.f);
    
    _titleFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.f];
    _detailFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.f];
    
    _contentInsets = UIEdgeInsetsMake(6.f, 12.f, 8.f, 12.f);
    _imagePadding = 15.f;
    _verticalTextPadding = 0.f;
    _maximumImageSize = CGSizeMake(50.f, 50.f);
    _animationDuration = 0.3;
    _imageOnTheRight = NO;
    _alignImageToText = NO;
    _titleTextAlignment = _detailTextAlignment = UITextAlignmentLeft;
    _textVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _imageVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _reduceImageSizeOnBothSides = NO;
    
    _minHeight = 44.f;
    _maxHeight = 100.f;
    
    intervalToHideAfter = kDGDropdownViewHideNever;
    showAnimated = YES;
    
    self.layer.shadowOffset = CGSizeMake(0.f, 1.f);
    self.layer.shadowRadius = 1.0f;
    self.layer.shadowColor = [UIColor colorWithWhite:0.450f alpha:1.0f].CGColor;
    self.layer.shadowOpacity = 1.0f;
    self.clipsToBounds = NO;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
    [self addGestureRecognizer:tapGestureRecognizer];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize_DGDropdownView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize_DGDropdownView];
    }
    return self;
}

+ (void)safeAddDropdownToArray:(DGDropdownView *)dropdown forView:(UIView *)view
{
    @synchronized(self)
    {
        NSMutableArray *array = objc_getAssociatedObject(view, ASSOCIATED_KEY);
        if (array == nil)
        {
            array = [[NSMutableArray alloc] init];
            objc_setAssociatedObject(view, ASSOCIATED_KEY, array, OBJC_ASSOCIATION_RETAIN);
        }
        [array addObject:dropdown];
    }
}

+ (void)safeRemoveDropdownFromArray:(DGDropdownView *)dropdown forView:(UIView *)view
{
    @synchronized(self)
    {
        NSMutableArray *array = objc_getAssociatedObject(view, ASSOCIATED_KEY);
        if (array == nil)
        {
            array = [[NSMutableArray alloc] init];
            objc_setAssociatedObject(view, ASSOCIATED_KEY, array, OBJC_ASSOCIATION_RETAIN);
        }
        [array removeObject:dropdown];
    }
}

+ (DGDropdownView *)safePeekDropdownFromArrayForView:(UIView *)view
{
    @synchronized(self)
    {
        NSMutableArray *array = objc_getAssociatedObject(view, ASSOCIATED_KEY);
        if (array == nil)
        {
            array = [[NSMutableArray alloc] init];
            objc_setAssociatedObject(view, ASSOCIATED_KEY, array, OBJC_ASSOCIATION_RETAIN);
        }
        
        if (!array.count) return nil;
        return array[0];
    }
}

+ (DGDropdownView *)safePopViewFromArrayForView:(UIView *)view
{
    @synchronized(self)
    {
        NSMutableArray *array = objc_getAssociatedObject(view, ASSOCIATED_KEY);
        if (array == nil)
        {
            array = [[NSMutableArray alloc] init];
            objc_setAssociatedObject(view, ASSOCIATED_KEY, array, OBJC_ASSOCIATION_RETAIN);
        }
        
        if (!array.count) return nil;
        DGDropdownView *dropdown = array[0];
        [array removeObjectAtIndex:0];
        return dropdown;
    }
}

- (NSArray *)colorsForGradientLayerWithColors:(NSArray *)colors
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (UIColor *color in colors)
    {
        [array addObject:(id)color.CGColor];
    }
    return [array copy];
}

- (void)layoutSubviews
{
    CGRect bounds = self.bounds, rc, availableSpace;
    
    if (backgroundLayer)
    {
        rc = bounds;
        if (self.bottomBorderWidth && self.bottomBorderColor)
        {
            rc.size.height -= self.bottomBorderWidth;
        }
        backgroundLayer.frame = rc;
    }
    if (bottomBorderLayer)
    {
        rc = bounds;
        rc.origin.y += rc.size.height - self.bottomBorderWidth;
        rc.size.height = self.bottomBorderWidth;
        bottomBorderLayer.frame = rc;
    }
    
    [self ensureSubviewsExist];
    
    bounds = availableSpace = UIEdgeInsetsInsetRect(bounds, self.contentInsets);
    
    CGSize sz;
    
    CGFloat absoluteMaxHeight = self.maxHeight;
    
    UIControlContentVerticalAlignment vAlign;
    BOOL alignImageToText = self.alignImageToText;
    BOOL imageOnTheRight = self.imageOnTheRight;
    BOOL hasImage = !!imageView.image;
    CGFloat imageTotalWidth = 0.f;
    
    if (hasImage)
    {
        vAlign = self.imageVerticalAlignment;
        
        // Calculate the size of the UIImageView
        sz = self.maximumImageSize;
        if (absoluteMaxHeight > 0.f && (sz.height > absoluteMaxHeight || sz.height <= 0.f))
        {
            sz.height = absoluteMaxHeight;
        }
        sz = [self frameForSize:imageView.image.size inBounds:sz];
        
        // Position it
        rc.size = sz;
        rc.origin = availableSpace.origin;
        if (imageOnTheRight && !alignImageToText)
        {
            rc.origin.x = availableSpace.origin.x + availableSpace.size.width - rc.size.width;
        }
        if (vAlign == UIControlContentVerticalAlignmentBottom)
        {
            rc.origin.y += availableSpace.size.height - rc.size.height;
        }
        else if (vAlign == UIControlContentVerticalAlignmentCenter)
        {
            rc.origin.y += (availableSpace.size.height - rc.size.height) / 2.f;
        }
        imageView.frame = rc;
        imageView.hidden = NO;
        
        if (sz.width > 0.f && sz.height > 0.f)
        {
            imageTotalWidth = sz.width + self.imagePadding;
            BOOL reduceImageSizeOnBothSides = self.reduceImageSizeOnBothSides && !alignImageToText;
            if (!imageOnTheRight || reduceImageSizeOnBothSides)
            {
                availableSpace.origin.x += imageTotalWidth;
            }
            availableSpace.size.width -= imageTotalWidth;
            if (reduceImageSizeOnBothSides)
            {
                availableSpace.size.width -= imageTotalWidth;
            }
        }
    }
    else
    {
        imageView.hidden = YES;
    }
    
    CGRect titleRect = CGRectMake(bounds.size.width / 2.f + bounds.origin.x, bounds.size.height / 2.f + bounds.origin.y, 0.f, 0.f), detailRect = titleRect;
    
    BOOL hasTitle = titleLabel.text.length > 0, hasDetail = detailLabel.text.length > 0;
    
    if (hasTitle)
    {
        sz = [titleLabel sizeThatFits:availableSpace.size];
        titleRect = availableSpace;
        titleRect.size.width = MIN(sz.width, titleRect.size.width);
        titleRect.size.height = MIN(sz.height, titleRect.size.height);
        
        if (titleLabel.textAlignment == UITextAlignmentRight)
        {
            titleRect.origin.x += availableSpace.size.width - titleRect.size.width;
        }
        else if (titleLabel.textAlignment == UITextAlignmentCenter)
        {
            titleRect.origin.x += (availableSpace.size.width - titleRect.size.width) / 2.f;
        }

        titleLabel.hidden = NO;
        
        if (sz.height > 0.f)
        {
            availableSpace.origin.y += sz.height + self.verticalTextPadding;
            availableSpace.size.height -= sz.height + self.verticalTextPadding;
        }
    }
    else
    {
        titleLabel.hidden = YES;
    }
    
    if (hasDetail)
    {
        sz = [detailLabel sizeThatFits:availableSpace.size];
        detailRect = availableSpace;
        detailRect.size.width = MIN(sz.width, detailRect.size.width);
        detailRect.size.height = MIN(sz.height, detailRect.size.height);
        
        if (detailLabel.textAlignment == UITextAlignmentRight)
        {
            detailRect.origin.x += availableSpace.size.width - detailRect.size.width;
        }
        else if (detailLabel.textAlignment == UITextAlignmentCenter)
        {
            detailRect.origin.x += (availableSpace.size.width - detailRect.size.width) / 2.f;
        }

        detailLabel.hidden = NO;
    }
    else
    {
        detailLabel.hidden = YES;
    }
    
    vAlign = self.textVerticalAlignment;
    if (vAlign == UIControlContentVerticalAlignmentBottom || vAlign == UIControlContentVerticalAlignmentCenter)
    {
        CGFloat totalLabelsHeight = 0.f;
        if (hasTitle)
        {
            totalLabelsHeight += titleRect.size.height;
        }
        if (hasDetail)
        {
            totalLabelsHeight += detailRect.size.height;
            if (hasTitle)
            {
                totalLabelsHeight += detailRect.origin.y - CGRectGetMaxY(titleRect);
            }
        }
        
        if (vAlign == UIControlContentVerticalAlignmentBottom)
        {
            totalLabelsHeight = bounds.size.height - totalLabelsHeight;
        }
        else if (vAlign == UIControlContentVerticalAlignmentCenter)
        {
            totalLabelsHeight = (bounds.size.height - totalLabelsHeight) / 2.f;
        }
        
        if (hasTitle)
        {
            titleRect.origin.y += totalLabelsHeight;
        }
        if (hasDetail)
        {
            detailRect.origin.y += totalLabelsHeight;
        }
    }
    
    if (alignImageToText && hasImage)
    {
        if (imageOnTheRight)
        {
            if (hasTitle)
            {
                titleRect.origin.x += imageTotalWidth / 2.f;
            }
            if (hasDetail)
            {
                detailRect.origin.x += imageTotalWidth / 2.f;
            }
        }
        else
        {
            if (hasTitle)
            {
                titleRect.origin.x -= imageTotalWidth / 2.f;
            }
            if (hasDetail)
            {
                detailRect.origin.x -= imageTotalWidth / 2.f;
            }
        }
        
        rc = imageView.frame;
        if (imageOnTheRight)
        {
            rc.origin.x = MAX(titleRect.origin.x + titleRect.size.width, detailRect.origin.x + detailRect.size.width) + self.imagePadding;
        }
        else
        {
            rc.origin.x = MIN(titleRect.origin.x, detailRect.origin.x) - self.imagePadding - rc.size.width;
        }
        imageView.frame = rc;
    }

    titleLabel.frame = titleRect;
    detailLabel.frame = detailRect;
}

- (void)ensureSubviewsExist
{
    if (!backgroundLayer && self.backgroundColors.count)
    {
        backgroundLayer = [[CAGradientLayer alloc] init];
        backgroundLayer.colors = [self colorsForGradientLayerWithColors:self.backgroundColors];
        backgroundLayer.locations = self.backgroundColorPositions;
        [self.layer insertSublayer:backgroundLayer atIndex:0];
    }
    if (!bottomBorderLayer && self.bottomBorderColor && self.bottomBorderWidth)
    {
        bottomBorderLayer = [[CALayer alloc] init];
        bottomBorderLayer.backgroundColor = self.bottomBorderColor.CGColor;
        [self.layer insertSublayer:bottomBorderLayer atIndex:1];
    }
    if (!titleLabel && self.title.length)
    {
        titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = self.titleTextColor;
        titleLabel.textAlignment = self.titleTextAlignment;
        titleLabel.shadowColor = self.titleShadowColor;
        titleLabel.shadowOffset = self.titleShadowOffset;
        titleLabel.font = self.titleFont;
        titleLabel.text = self.title;
        titleLabel.numberOfLines = 0;
        [self addSubview:titleLabel];
    }
    if (!detailLabel && self.detail.length)
    {
        detailLabel = [[UILabel alloc] init];
        detailLabel.backgroundColor = [UIColor clearColor];
        detailLabel.textColor = self.detailTextColor;
        detailLabel.textAlignment = self.detailTextAlignment;
        detailLabel.shadowColor = self.detailShadowColor;
        detailLabel.shadowOffset = self.detailShadowOffset;
        detailLabel.font = self.detailFont;
        detailLabel.text = self.detail;
        detailLabel.numberOfLines = 0;
        [self addSubview:detailLabel];
    }
    if (!imageView && self.image)
    {
        imageView = [[UIImageView alloc] initWithImage:self.image];
        [self addSubview:imageView];
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    [super layoutIfNeeded]; // Invoke UIAppearance invocations
    [self ensureSubviewsExist];
    
    CGFloat absoluteMaxHeight = self.maxHeight;
    
    CGFloat availableWidth = size.width;
    
    CGSize result = {size.width, 0.f};
    UIEdgeInsets insets = self.contentInsets;
    availableWidth -= insets.left + insets.right;
    result.height += insets.top + insets.bottom;
    CGSize maxImageSize = self.maximumImageSize;
    if (absoluteMaxHeight > 0.f && (maxImageSize.height > absoluteMaxHeight || maxImageSize.height <= 0.f))
    {
        maxImageSize.height = absoluteMaxHeight;
    }
    CGSize imageSize = [self frameForSize:imageView.image.size inBounds:maxImageSize];
    CGFloat maxHeight = 0.f;
    if (imageSize.width > 0.f)
    {
        CGFloat imageTotalWidth = imageSize.width + self.imagePadding;
        availableWidth -= imageTotalWidth;
        if (self.reduceImageSizeOnBothSides && !self.alignImageToText)
        {
            availableWidth -= imageTotalWidth;
        }
    }
    if (imageSize.height > 0.f)
    {
        maxHeight = MAX(imageSize.height, maxHeight);
    }
    
    CGSize titleSize = [titleLabel sizeThatFits:CGSizeMake(availableWidth, absoluteMaxHeight > 0.f ? absoluteMaxHeight : 9999.f)];
    CGSize detailSize = [detailLabel sizeThatFits:CGSizeMake(availableWidth, absoluteMaxHeight > 0.f ? absoluteMaxHeight : 9999.f)];
    
    CGFloat labelsMaxHeight = titleSize.height + detailSize.height;
    if (titleSize.height > 0.f && detailSize.height > 0.f)
    {
        labelsMaxHeight += self.verticalTextPadding;
    }
    if (absoluteMaxHeight > 0.f &&
        absoluteMaxHeight < (labelsMaxHeight + result.height))
    {
        labelsMaxHeight = absoluteMaxHeight - result.height;
        if (titleSize.height > 0.f &&
            labelsMaxHeight <= titleSize.height + self.verticalTextPadding &&
            self.textVerticalAlignment == UIControlContentVerticalAlignmentTop)
        {
            // The second label does not fit in at all, and we are vertical aligning to top, so the it is unneeded
            labelsMaxHeight = titleSize.height;
        }
    }
    maxHeight = MAX(labelsMaxHeight, maxHeight) + result.height;
    
    result.height = MIN(absoluteMaxHeight, maxHeight);
    if (self.bottomBorderColor)
    {
        result.height += self.bottomBorderWidth;
    }
    return result;
}

- (CGSize)frameForSize:(CGSize)size inBounds:(CGSize)bounds
{
    if ((size.width <= bounds.width || bounds.width <= 0.f) && (size.height <= bounds.height || bounds.height <= 0.f))
    {
        return size;
    }
    else
    {
        CGFloat ratio = size.height == 0 ? 1 : (size.width / size.height);
        if (bounds.width <= 0.f)
        {
            bounds.height = MIN(bounds.height, size.height);
            bounds.width = bounds.height *ratio;
        }
        else if (bounds.height <= 0.f)
        {
            bounds.width = MIN(bounds.width, size.width);
            bounds.height = bounds.width / ratio;
        }
        else
        {
            CGFloat newRatio = bounds.height == 0 ? 1 : (bounds.width / bounds.height);
            
            if (newRatio > ratio)
            {
                bounds.width = bounds.height *ratio;
            }
            else if (newRatio < ratio)
            {
                bounds.height = bounds.width / ratio;
            }
        }
        return bounds;
    }
}

#pragma mark - Properties

- (void)setBackgroundColors:(NSArray *)backgroundColors
{
    _backgroundColors = backgroundColors;
    backgroundLayer.colors = [self colorsForGradientLayerWithColors:_backgroundColors];
}

- (void)setBackgroundColorPositions:(NSArray *)backgroundColorPositions
{
    _backgroundColorPositions = backgroundColorPositions;
    backgroundLayer.locations = _backgroundColorPositions;
}

- (void)setBottomBorderColor:(UIColor *)bottomBorderColor
{
    _bottomBorderColor = bottomBorderColor;
    bottomBorderLayer.backgroundColor = _bottomBorderColor.CGColor;
    [self setNeedsLayout];
}

- (void)setBottomBorderWidth:(CGFloat)bottomBorderWidth
{
    _bottomBorderWidth = bottomBorderWidth;
    [self setNeedsLayout];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    titleLabel.text = _title;
    [self setNeedsLayout];
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    titleLabel.font = _titleFont;
    [self setNeedsLayout];
}

- (void)setTitleTextColor:(UIColor *)titleTextColor
{
    _titleTextColor = titleTextColor;
    titleLabel.textColor = _titleTextColor;
    [self setNeedsLayout];
}

- (void)setTitleTextAlignment:(UITextAlignment)titleTextAlignment
{
    _titleTextAlignment = titleTextAlignment;
    titleLabel.textAlignment = titleTextAlignment;
    [self setNeedsLayout];
}

- (void)setTitleShadowColor:(UIColor *)titleShadowColor
{
    _titleShadowColor = titleShadowColor;
    titleLabel.shadowColor = titleShadowColor;
    [self setNeedsLayout];
}

- (void)setTitleShadowOffset:(CGSize)titleShadowOffset
{
    _titleShadowOffset = titleShadowOffset;
    titleLabel.shadowOffset = titleShadowOffset;
    [self setNeedsLayout];
}

- (void)setDetail:(NSString *)detail
{
    _detail = detail;
    detailLabel.text = _detail;
    [self setNeedsLayout];
}

- (void)setDetailFont:(UIFont *)detailFont
{
    _detailFont = detailFont;
    detailLabel.font = _detailFont;
    [self setNeedsLayout];
}

- (void)setDetailTextColor:(UIColor *)detailTextColor
{
    _detailTextColor = detailTextColor;
    detailLabel.textColor = _detailTextColor;
    [self setNeedsLayout];
}

- (void)setDetailTextAlignment:(UITextAlignment)detailTextAlignment
{
    _detailTextAlignment = detailTextAlignment;
    detailLabel.textAlignment = detailTextAlignment;
    [self setNeedsLayout];
}

- (void)setDetailShadowColor:(UIColor *)detailShadowColor
{
    _detailShadowColor = detailShadowColor;
    detailLabel.shadowColor = detailShadowColor;
    [self setNeedsLayout];
}

- (void)setDetailShadowOffset:(CGSize)detailShadowOffset
{
    _detailShadowOffset = detailShadowOffset;
    detailLabel.shadowOffset = detailShadowOffset;
    [self setNeedsLayout];
}

- (void)setTextVerticalAlignment:(UIControlContentVerticalAlignment)textVerticalAlignment
{
    _textVerticalAlignment = textVerticalAlignment;
    [self setNeedsLayout];
}

- (void)setImageVerticalAlignment:(UIControlContentVerticalAlignment)imageVerticalAlignment
{
    _imageVerticalAlignment = imageVerticalAlignment;
    [self setNeedsLayout];
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    _contentInsets = contentInsets;
    [self setNeedsLayout];
}

- (void)setVerticalTextPadding:(CGFloat)verticalTextPadding
{
    _verticalTextPadding = verticalTextPadding;
    [self setNeedsLayout];
}

- (void)setImagePadding:(CGFloat)imagePadding
{
    _imagePadding = imagePadding;
    [self setNeedsLayout];
}

- (void)setMaximumImageSize:(CGSize)maximumImageSize
{
    _maximumImageSize = maximumImageSize;
    [self setNeedsLayout];
}

- (void)setAnimationDuration:(CGFloat)animationDuration
{
    _animationDuration = animationDuration;
    [self setNeedsLayout];
}

- (void)setImageOnTheRight:(BOOL)imageOnTheRight
{
    _imageOnTheRight = imageOnTheRight;
    [self setNeedsLayout];
}

- (void)setAlignImageToText:(BOOL)alignImageToText
{
    _alignImageToText = alignImageToText;
    [self setNeedsLayout];
}

- (void)setMaxHeight:(CGFloat)maxHeight
{
    _maxHeight = maxHeight;
    [self setNeedsLayout];
}

- (void)setMinHeight:(CGFloat)minHeight
{
    _minHeight = minHeight;
    [self setNeedsLayout];
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    [self setNeedsLayout];
}

#pragma mark - Actions

- (void)tapGestureRecognized:(UITapGestureRecognizer *)recognizer
{
    if (actionTarget && actionSelector)
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [actionTarget performSelector:actionSelector withObject:self];
#pragma clang diagnostic pop
    }
    [self hideDropDown];
}

#pragma mark - Methods

- (void)doShow
{
    if (self.superview) return;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL isInWindow = showInView == [UIApplication sharedApplication].keyWindow;
    
    [showInView addSubview:self];
    
    [self resetOrientation];
    
    if (showAnimated)
    {
        CGRect targetFrame = self.frame;
        CGRect fromFrame = targetFrame;
        
        if (isInWindow)
        {
            if (orientation == UIInterfaceOrientationPortraitUpsideDown)
            {
                fromFrame.origin.y += fromFrame.size.height;
            }
            else if (orientation == UIInterfaceOrientationLandscapeLeft)
            {
                fromFrame.origin.x -= fromFrame.size.width;
            }
            else if (orientation == UIInterfaceOrientationLandscapeRight)
            {
                fromFrame.origin.x += fromFrame.size.width;
            }
            else
            {
                fromFrame.origin.y -= fromFrame.size.height;
            }
        }
        else
        {
            fromFrame.origin.y -= fromFrame.size.height;
        }
        
        self.frame = fromFrame;
        
        [UIView animateWithDuration:self.animationDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             self.frame = targetFrame;
                             
                         }
                         completion:^(BOOL finished) {
                             if (finished)
                             {
                                 
                             }
                         }];
    }
    
    if (intervalToHideAfter != kDGDropdownViewHideNever)
    {
        double delayInSeconds = self.animationDuration + intervalToHideAfter;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds *NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [self hideDropDownAnimated:showAnimated];
            
        });
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flipViewToOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)flipViewToOrientation:(NSNotification *)notification
{
    if ([self.class safePeekDropdownFromArrayForView:showInView] != self) return;
    
    [self resetOrientation];
}

- (void)resetOrientation
{
    CGSize requiredSize;
    CGRect containerBounds;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL isInWindow = showInView == [UIApplication sharedApplication].keyWindow;
    if (isInWindow)
    {
        containerBounds = [UIScreen mainScreen].applicationFrame;
    }
    else
    {
        containerBounds = showInView.bounds;
    }
    BOOL rotatedScreen = isInWindow && UIInterfaceOrientationIsLandscape(orientation);
    if (rotatedScreen)
    {
        requiredSize = [self sizeThatFits:CGSizeMake(containerBounds.size.height, 0.f)];
    }
    else
    {
        requiredSize = [self sizeThatFits:CGSizeMake(containerBounds.size.width, 0.f)];
    }
    
    self.transform = CGAffineTransformIdentity;
    
    CGRect frame;
    
    if (isInWindow)
    {
        CGFloat angle = 0.0;
        switch (orientation)
        {
            case UIInterfaceOrientationPortraitUpsideDown:
                angle = M_PI;
                frame.origin.y = containerBounds.size.height + containerBounds.origin.y - requiredSize.height;
                frame.origin.x = containerBounds.origin.x;
                frame.size = requiredSize;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                angle = - M_PI / 2.0f;
                frame.origin = containerBounds.origin;
                frame.size.width = requiredSize.height;
                frame.size.height = requiredSize.width;
                break;
            case UIInterfaceOrientationLandscapeRight:
                angle = M_PI / 2.0f;
                frame.origin.x = containerBounds.origin.x + containerBounds.size.width - requiredSize.height;
                frame.origin.y = containerBounds.origin.y;
                frame.size.width = requiredSize.height;
                frame.size.height = requiredSize.width;
                break;
            default: // as UIInterfaceOrientationPortrait
                angle = 0.0;
                frame.origin = containerBounds.origin;
                frame.size = requiredSize;
                break;
        }
        self.transform = CGAffineTransformMakeRotation(angle);
        self.frame = frame;
    }
    else
    {
        frame.origin = containerBounds.origin;
        frame.size = requiredSize;
        self.frame = frame;
    }
}

+ (DGDropdownView *)visibleDropdownInView:(UIView *)view
{
    return [self safePeekDropdownFromArrayForView:view];
}

+ (DGDropdownView *)dropdownViewWithTitle:(NSString *)title
                                  detail:(NSString *)detail
                                   image:(UIImage *)image
{
    DGDropdownView *dropdown = [[DGDropdownView alloc] init];
    dropdown.title = title;
    dropdown.detail = detail;
    dropdown.image = image;
    return dropdown;
}

- (DGDropdownView *)showInView:(UIView *)view
                      animated:(BOOL)animated
                     hideAfter:(NSTimeInterval)hideAfter
{
    if (view == nil)
    {
        view = [UIApplication sharedApplication].keyWindow;
    }
    showInView = view;
    showAnimated = animated;
    intervalToHideAfter = hideAfter;
    [self.class safeAddDropdownToArray:self forView:showInView];
    if (self == [self.class safePeekDropdownFromArrayForView:showInView])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[self.class safePeekDropdownFromArrayForView:showInView] doShow];
            
        });
    }
    return self;
}

- (DGDropdownView *)showInView:(UIView *)view
                      animated:(BOOL)animated
{
    return [self showInView:view animated:animated hideAfter:kDGDropdownViewHideNever];
}

- (DGDropdownView *)showInView:(UIView *)view
                     hideAfter:(NSTimeInterval)hideAfter
{
    return [self showInView:view animated:YES hideAfter:hideAfter];
}

- (DGDropdownView *)showInView:(UIView *)view
{
    return [self showInView:view animated:YES hideAfter:kDGDropdownViewHideNever];
}

- (DGDropdownView *)showAnimated:(BOOL)animated
                       hideAfter:(NSTimeInterval)hideAfter
{
    return [self showInView:nil animated:animated hideAfter:hideAfter];
}

- (DGDropdownView *)showAnimated:(BOOL)animated
{
    return [self showInView:nil animated:animated hideAfter:kDGDropdownViewHideNever];
}

- (DGDropdownView *)showHideAfter:(NSTimeInterval)hideAfter
{
    return [self showInView:nil animated:YES hideAfter:hideAfter];
}

- (DGDropdownView *)show
{
    return [self showInView:nil animated:YES hideAfter:kDGDropdownViewHideNever];
}

+ (DGDropdownView *)showDropdownInView:(UIView *)view
                                 title:(NSString *)title
                                detail:(NSString *)detail
                                 image:(UIImage *)image
                              animated:(BOOL)animated
                             hideAfter:(NSTimeInterval)hideAfter
{
    DGDropdownView *dropdown = [[DGDropdownView alloc] init];
    dropdown.title = title;
    dropdown.detail = detail;
    dropdown.image = image;
    return [dropdown showInView:view animated:animated hideAfter:hideAfter];
}

+ (DGDropdownView *)showDropdownInView:(UIView *)view
                                 title:(NSString *)title
                                detail:(NSString *)detail
                                 image:(UIImage *)image
                             hideAfter:(NSTimeInterval)hideAfter
{
    return [self showDropdownInView:view title:title detail:detail image:image animated:YES hideAfter:hideAfter];
}

+ (DGDropdownView *)showDropdownInView:(UIView *)view
                                 title:(NSString *)title
                                detail:(NSString *)detail
                                 image:(UIImage *)image
                              animated:(BOOL)animated
{
    return [self showDropdownInView:view title:title detail:detail image:image animated:animated hideAfter:kDGDropdownViewHideNever];
}

+ (DGDropdownView *)showDropdownInView:(UIView *)view
                                 title:(NSString *)title
                                detail:(NSString *)detail
                                 image:(UIImage *)image
{
    return [self showDropdownInView:view title:title detail:detail image:image animated:YES hideAfter:kDGDropdownViewHideNever];
}

+ (DGDropdownView *)showDropdownWithTitle:(NSString *)title
                                   detail:(NSString *)detail
                                    image:(UIImage *)image
                                 animated:(BOOL)animated
                                hideAfter:(NSTimeInterval)hideAfter
{
    return [self showDropdownInView:nil title:title detail:detail image:image animated:animated hideAfter:hideAfter];
}

+ (DGDropdownView *)showDropdownWithTitle:(NSString *)title
                                   detail:(NSString *)detail
                                    image:(UIImage *)image
                                hideAfter:(NSTimeInterval)hideAfter
{
    return [self showDropdownInView:nil title:title detail:detail image:image animated:YES hideAfter:hideAfter];
}

+ (DGDropdownView *)showDropdownWithTitle:(NSString *)title
                                   detail:(NSString *)detail
                                    image:(UIImage *)image
                                 animated:(BOOL)animated
{
    return [self showDropdownInView:nil title:title detail:detail image:image animated:animated hideAfter:kDGDropdownViewHideNever];
}

+ (DGDropdownView *)showDropdownWithTitle:(NSString *)title
                                   detail:(NSString *)detail
                                    image:(UIImage *)image
{
    return [self showDropdownInView:nil title:title detail:detail image:image animated:YES hideAfter:kDGDropdownViewHideNever];
}

- (DGDropdownView *)hideDropDown
{
    return [self hideDropDownAnimated:YES];
}

- (DGDropdownView *)hideDropDownAnimated:(BOOL)animated
{
    [self.class safeRemoveDropdownFromArray:self forView:showInView];
    
    if (!self.superview) return self;
    
    if (animated)
    {
        CGRect fromFrame = self.frame;
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        BOOL isInWindow = showInView == [UIApplication sharedApplication].keyWindow;
        
        if (isInWindow)
        {
            if (orientation == UIInterfaceOrientationPortraitUpsideDown)
            {
                fromFrame.origin.y += fromFrame.size.height;
            }
            else if (orientation == UIInterfaceOrientationLandscapeLeft)
            {
                fromFrame.origin.x -= fromFrame.size.width;
            }
            else if (orientation == UIInterfaceOrientationLandscapeRight)
            {
                fromFrame.origin.x += fromFrame.size.width;
            }
            else
            {
                fromFrame.origin.y -= fromFrame.size.height;
            }
        }
        else
        {
            fromFrame.origin.y -= fromFrame.size.height;
        }
        
        [UIView animateWithDuration:self.animationDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             self.frame = fromFrame;
                             
                         }
                         completion:^(BOOL finished) {
                             [self removeFromSuperview];
                             [[NSNotificationCenter defaultCenter] removeObserver:self];
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 
                                 [[self.class safePeekDropdownFromArrayForView:showInView] doShow];
                                 
                             });
                             
                         }];
    }
    else
    {
        [self removeFromSuperview];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[self.class safePeekDropdownFromArrayForView:showInView] doShow];
            
        });
    }
    
    return self;
}

+ (DGDropdownView *)hideDropDownInView:(UIView *)view
{
    DGDropdownView *dropdown = [self safePeekDropdownFromArrayForView:view];
    [dropdown hideDropDown];
    return dropdown;
}

+ (DGDropdownView *)hideDropDownInView:(UIView *)view animated:(BOOL)animated
{
    DGDropdownView *dropdown = [self safePeekDropdownFromArrayForView:view];
    [dropdown hideDropDownAnimated:animated];
    return dropdown;
}

+ (DGDropdownView *)hideDropDown
{
    return [self hideDropDownInView:nil];
}

+ (DGDropdownView *)hideDropDownAnimated:(BOOL)animated
{
    return [self hideDropDownInView:nil animated:animated];
}

- (DGDropdownView *)setTouchUpInsideTarget:(id)target action:(SEL)action
{
    actionTarget = target;
    actionSelector = action;
    return self;
}

@end
