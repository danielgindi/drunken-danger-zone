//
//  DGCompatibleSegmentedControl.m
//  DGCompatibleSegmentedControl
//
//  Created by Daniel Cohen Gindi on 6/15/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGCompatibleSegmentedControl.h"
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_FONT [UIFont fontWithName:@"HelveticaNeue" size:13.f]

// iOS 5 support, to be dropped soon
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
#define NSTextAlignmentLeft UITextAlignmentLeft
#define NSTextAlignmentRight UITextAlignmentRight
#define NSTextAlignmentCenter UITextAlignmentCenter
#endif

@implementation DGCompatibleSegmentedControl
{
    NSMutableArray *segmentRects;
    NSMutableArray *buttons;
    NSMutableArray *contentViews;
    NSMutableArray *separators;
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    size.height = 29.f;
    return size;
}

- (void)setFrame:(CGRect)frame
{
    frame.size.height = 29.f;
    [super setFrame:frame];
}

- (void)setBounds:(CGRect)bounds
{
    bounds.size.height = 29.f;
    [super setBounds:bounds];
}

- (void)tintColorDidChange
{
    self.layer.borderColor = self.tintColor.CGColor;
    
    UIColor *tintColor = self.tintColor;
    int selectedSegment = self.selectedSegmentIndex;
    for (int j=0; j<buttons.count; j++)
    {
        ((UIButton*)buttons[j]).backgroundColor = (selectedSegment) == j ? tintColor : UIColor.clearColor;
        if ([contentViews[j] isKindOfClass:UILabel.class])
        {
            ((UILabel*)buttons[j]).textColor = (selectedSegment) == j ? ([tintColor isEqual:UIColor.whiteColor]?UIColor.blackColor:UIColor.whiteColor) : tintColor;
        }
    }    for (UIView *separator in separators)
    {
        separator.backgroundColor = tintColor;
    }
}

- (void)layoutSubviews
{
	for (UIView *subView in self.subviews)
    {
		[subView removeFromSuperview];
	}
    
    // Calculate segment sizes
    
    int numberOfSegments = self.numberOfSegments;
    CGRect rc = self.frame, rc2;
    CGFloat totalWidth = rc.size.width, width;
    CGFloat *widths = malloc(sizeof(CGFloat)*numberOfSegments);
    segmentRects = [[NSMutableArray alloc] init];
    for (int j=0; j<numberOfSegments; j++)
    {
        widths[j] = [self widthForSegmentAtIndex:j];
        if (widths[j] > 0.f)
        { // For each segment that is fixed-sized
            if (widths[j] > totalWidth)
            { // Truncate if there's no more room
                widths[j] = totalWidth;
            }
            totalWidth -= widths[j];
        }
    }
    
    // Calculate variable-width-sized segments
    
    UIImage *image;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    NSString *title;
#else
    NSAttributedString *attTitle;
#endif
    UIFont *defaultFont = DEFAULT_FONT;
    
    if (self.apportionsSegmentWidthsByContent)
    {
        NSMutableArray *flexWidths = [[NSMutableArray alloc] init];
        CGFloat totalFlexWidth = 0.f;
        for (int j=0; j<numberOfSegments; j++)
        {
            if (widths[j] > 0.f) continue;
            
            image = [self imageForSegmentAtIndex:j];
            if (image)
            {
                width = image.size.width;
            }
            else
            {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
                title = [self titleForSegmentAtIndex:j];
                width = [title sizeWithFont:defaultFont constrainedToSize:(CGSize){9999.f, 9999.f} lineBreakMode:UILineBreakModeClip].width;
#else
                attTitle = [self attributedStringForSegment:j];
                width = [attTitle size].width;
#endif
            }
            
            [flexWidths addObject:@(width)];
            totalFlexWidth += width;
        }
        
        for (int j=0; j<numberOfSegments; j++)
        {
            if (widths[j] > 0.f) continue;
            
            widths[j] = ([flexWidths[j] floatValue] / totalFlexWidth) * totalWidth;
        }
    }
    
    if (totalWidth > 0.f)
    {
        CGFloat leftOver = (CGFloat)numberOfSegments;
        for (int j=0; j<numberOfSegments; j++)
        {
            widths[j] += totalWidth / leftOver;
        }
    }
    
    rc.origin.x = rc.origin.y = 0.f;
    for (int j=0; j<numberOfSegments; j++)
    {
        rc.size.width = widths[j];
        [segmentRects addObject:[NSValue valueWithCGRect:rc]];
        rc.origin.x += rc.size.width;
    }
    
    free(widths);
    
    // Create subviews
    buttons = [[NSMutableArray alloc] init];
    contentViews = [[NSMutableArray alloc] init];
    separators = [[NSMutableArray alloc] init];
    
    UIButton *button;
    UIView *separator;
    UIImageView *imageView;
    UILabel *label;
    CGSize contentOffset;
    for (int j=0; j<numberOfSegments; j++)
    {
        if (j > 0)
        {
            separator = [[UIView alloc] initWithFrame:(CGRect){{rc.origin.x + rc.size.width, 0.f}, {1.f, rc.size.height}}];
            separator.backgroundColor = self.tintColor;
            [self addSubview:separator];
            [separators addObject:separator];
        }
        
        rc = [((NSValue*)segmentRects[j]) CGRectValue];
        button = [[UIButton alloc] initWithFrame:rc];
        button.backgroundColor = UIColor.clearColor;
        button.enabled = [self isEnabledForSegmentAtIndex:j];
        
        [self addSubview:button];
        [buttons addObject:button];
        
        contentOffset = [self contentOffsetForSegmentAtIndex:j];
        
        image = [self imageForSegmentAtIndex:j];
        if (image)
        {
            imageView = [[UIImageView alloc] initWithImage:image];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            rc2.origin.x = rc.origin.x + (rc.size.width - image.size.width) / 2.f;
            rc2.origin.y = rc.origin.y + (rc.size.height - image.size.height) / 2.f;
            rc2.size = image.size;
            rc2.origin.x += contentOffset.width;
            rc2.origin.y += contentOffset.height;
            if (rc2.origin.x + rc2.size.width > rc.origin.x + rc.size.width)
            {
                rc2.size.width -= (rc2.origin.x + rc2.size.width) - (rc.origin.x + rc.size.width);
            }
            if (rc2.origin.y + rc2.size.height > rc.origin.y + rc.size.height)
            {
                rc2.size.height -= (rc2.origin.y + rc2.size.height) - (rc.origin.y + rc.size.height);
            }
            
            imageView.frame = rc;
            [self addSubview:imageView];
            [contentViews addObject:imageView];
        }
        else
        {
            rc2 = rc;
            rc2.origin.x += contentOffset.width;
            rc2.origin.y += contentOffset.height;
            rc2.size.width -= contentOffset.width;
            rc2.size.height -= contentOffset.height;
            rc2.size.height -= 1.f; // Better vertical centering
            
            label = [[UILabel alloc] initWithFrame:rc2];
            label.backgroundColor = UIColor.clearColor;
            label.font = defaultFont;
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = self.tintColor;
            
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
            title = [self titleForSegmentAtIndex:j];
            width = [title sizeWithFont:defaultFont constrainedToSize:(CGSize){9999.f, 9999.f} lineBreakMode:UILineBreakModeClip].width;
            label.text = title;
#else
            attTitle = [self attributedStringForSegment:j];
            width = [attTitle size].width;
            label.attributedText = attTitle;
#endif
            
            label.frame = rc;
            [self addSubview:label];
            [contentViews addObject:label];
        }
        
        [button addTarget:self action:@selector(buttonTouchedDown:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(buttonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(buttonTouchedUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [button addTarget:self action:@selector(buttonTouchedUpOutside:) forControlEvents:UIControlEventTouchCancel];
    }
    
    [self showSelectionForSegment:self.selectedSegmentIndex selected:YES];
    
    self.layer.cornerRadius = 4.f;
    self.layer.borderColor = self.tintColor.CGColor;
    self.layer.borderWidth = 1.f;
    self.layer.masksToBounds = YES;
}

- (NSAttributedString*)attributedStringForSegment:(int)j
{
    NSString *titleString = [self titleForSegmentAtIndex:j];
    if (!titleString.length)
    {
        return [[NSAttributedString alloc] initWithString:@""];
    }
    
    NSMutableDictionary *titleAttributes = [[self titleTextAttributesForState:j] mutableCopy];
    if (!titleAttributes)
    {
        titleAttributes = [[NSMutableDictionary alloc] init];
    }
    if (!titleAttributes[NSFontAttributeName])
    {
        titleAttributes[NSFontAttributeName] = DEFAULT_FONT;
    }
    if (!titleAttributes[NSForegroundColorAttributeName])
    {
        UIColor *color = self.tintColor;
        if (!color) color = UIColor.darkTextColor; // Fallback
        titleAttributes[NSForegroundColorAttributeName] = color;
    }
    
    return [[NSAttributedString alloc] initWithString:titleString attributes:titleAttributes];
}

#pragma mark - Actions

- (void)showSelectionForSegment:(int)index selected:(BOOL)selected
{
    if (index == NSNotFound) return;
    
    UIButton *button = buttons[index];
    button.backgroundColor = selected ? self.tintColor : UIColor.clearColor;
    UIView *content = contentViews[index];
    if ([content isKindOfClass:UILabel.class])
    {
        UILabel *label = (UILabel*)content;
        if (selected)
        {
            if ([self.tintColor isEqual:UIColor.whiteColor])
            {
                label.textColor = UIColor.blackColor;
            }
            else
            {
                label.textColor = UIColor.whiteColor;
            }
        }
        else
        {
            label.textColor = self.tintColor;
        }
    }
    else
    {
        // I'm not gonna implement image tinting for this...
    }
}

- (void)buttonTouchedDown:(UIButton*)sender
{
    int index = [buttons indexOfObject:sender];
    if (index == NSNotFound) return;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self showSelectionForSegment:index selected:YES];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)buttonTouchedUpInside:(UIButton*)sender
{
    int index = [buttons indexOfObject:sender];
    if (index == NSNotFound) return;
    
    if (self.selectedSegmentIndex == index) return;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
        
        if (self.momentary)
        {
            [self showSelectionForSegment:index selected:NO];
            self.selectedSegmentIndex = index;
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            self.selectedSegmentIndex = UISegmentedControlNoSegment;
        }
        else
        {
            [self showSelectionForSegment:index selected:YES];
            self.selectedSegmentIndex = index;
        }
        
        for (int j=0; j<self.numberOfSegments; j++)
        {
            if (j!=index)
            {
                [self showSelectionForSegment:j selected:NO];
            }
        }
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)buttonTouchedUpOutside:(UIButton*)sender
{
    int index = [buttons indexOfObject:sender];
    if (index == NSNotFound) return;
    
    if (self.selectedSegmentIndex == index) return;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self showSelectionForSegment:index selected:NO];
        
    } completion:^(BOOL finished) {
        
    }];
}

#endif

@end
