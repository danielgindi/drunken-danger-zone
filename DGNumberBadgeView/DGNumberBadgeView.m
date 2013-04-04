//
//  DGNumberBadgeView.m
//  DGNumberBadgeView
//
//  Created by Daniel Cohen Gindi on 4/18/12.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//

#import "DGNumberBadgeView.h"

@interface DGNumberBadgeView ()
{
    CGSize lastBadgePathSize;
    CGPathRef lastBadgePath;
}
@end

@implementation DGNumberBadgeView

- (void)initialize_DGNumberBadgeView;
{
	self.opaque = NO;
    self.clipsToBounds = NO;
    
	_pad = 2;
	_font = [UIFont boldSystemFontOfSize:16];
	_shadow = YES;
	_shadowOffset = CGSizeMake(0, 3);
    _shadowBlurSize = 4.f;
	_shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
	_shine = YES;
	_alignment = UITextAlignmentCenter;
	_fillColor = [UIColor redColor];
	_strokeColor = [UIColor whiteColor];
	_strokeWidth = 2.0;
	_textColor = [UIColor whiteColor];
    _hideWhenZero = NO;
    
    lastBadgePath = NULL;
    lastBadgePathSize = CGSizeZero;
    
	self.backgroundColor = [UIColor clearColor];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
		[self initialize_DGNumberBadgeView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
	if (self)
	{
		[self initialize_DGNumberBadgeView];
    }
    return self;
}

- (void)dealloc
{
    if (lastBadgePath)
    {
        CGPathRelease(lastBadgePath);
        lastBadgePath = NULL;
    }
}

+ (NSMutableDictionary*)badgeViewMapDictionary
{
    static NSMutableDictionary * dict = nil;
    if (!dict)
    {
        @synchronized(self)
        {
            dict = [[NSMutableDictionary alloc] init];
        }
    }
    return dict;
}

+ (DGNumberBadgeView*)badgeForView:(UIView *)view
{
    NSMutableDictionary * dict = self.class.badgeViewMapDictionary;
    DGNumberBadgeView * badge = dict[view];
    if (!badge)
    {
        badge = [[DGNumberBadgeView alloc] init];
        badge.hidden = badge.hideWhenZero && badge.value == 0;
        badge.attachedToView = view;
        [view addSubview:badge];
        dict[[@((NSInteger)(id)view) stringValue]] = badge;
    }
    return badge;
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    if (_attachedToView)
    {
        NSMutableDictionary * dict = self.class.badgeViewMapDictionary;
        [dict removeObjectForKey:[@((NSInteger)(id)_attachedToView) stringValue]];
        _attachedToView = nil;
    }
}

- (void)setAttachedToView:(UIView *)attachedToView
{
    if (attachedToView || self.superview == _attachedToView)
    {
        [self removeFromSuperview];
    }
    if (attachedToView != _attachedToView)
    {
        _attachedToView = attachedToView;
        NSMutableDictionary * dict = self.class.badgeViewMapDictionary;
        dict[[@((NSInteger)(id)_attachedToView) stringValue]] = self;
    }
    [attachedToView addSubview:self];
}

- (void)setAnchor:(DGNumberBadgeViewAnchor)anchor
{
    _anchor = anchor;
    [self setNeedsLayout];
}

- (void)setInnerAnchor:(DGNumberBadgeViewAnchor)innerAnchor
{
    _innerAnchor = innerAnchor;
    [self setNeedsLayout];
}

- (void)setAnchorOffset:(CGSize)anchorOffset
{
    _anchorOffset = anchorOffset;
    [self setNeedsLayout];
}

- (void)setValue:(NSUInteger)inValue
{
	_value = inValue;
    
    self.hidden = self.hideWhenZero && _value == 0;
    
	[self setNeedsDisplay];
    [self setNeedsLayout];
}

- (void)setStrokeWidth:(CGFloat)strokeWidth
{
    _strokeWidth = strokeWidth;
    [self setNeedsLayout];
}

- (void)setShadow:(BOOL)shadow
{
    _shadow = shadow;
    [self setNeedsLayout];
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
    _shadowOffset = shadowOffset;
    [self setNeedsLayout];
}

- (void)setShadowBlurSize:(CGFloat)shadowBlurSize
{
    _shadowBlurSize = shadowBlurSize;
    [self setNeedsLayout];
}

- (void)repositionInMaster
{
    if (!self.attachedToView)
    {
        return;
    }
    
    CGRect frame = {{0.f, 0.f}, [self sizeThatFits:CGSizeZero]};
    CGRect bounds = self.attachedToView.bounds;
    CGSize innerOffset = self.anchorOffset;
    
    switch (self.innerAnchor)
    {
        case DGNumberBadgeViewAnchorTopLeft:
            break;
        case DGNumberBadgeViewAnchorTop:
            innerOffset.width -= frame.size.width / 2.f;
            break;
        case DGNumberBadgeViewAnchorTopRight:
            innerOffset.width = -innerOffset.width;
            innerOffset.width -= frame.size.width;
            break;
        case DGNumberBadgeViewAnchorCenterLeft:
            innerOffset.height -= frame.size.height / 2.f;
            break;
        case DGNumberBadgeViewAnchorCenter:
            innerOffset.width -= frame.size.width / 2.f;
            innerOffset.height -= frame.size.height / 2.f;
            break;
        case DGNumberBadgeViewAnchorCenterRight:
            innerOffset.width = -innerOffset.width;
            innerOffset.width -= frame.size.width;
            innerOffset.height -= frame.size.height / 2.f;
            break;
        case DGNumberBadgeViewAnchorBottomLeft:
            innerOffset.height = -innerOffset.height;
            innerOffset.height -= frame.size.height;
            break;
        case DGNumberBadgeViewAnchorBottom:
            innerOffset.width -= frame.size.width / 2.f;
            innerOffset.height = -innerOffset.height;
            innerOffset.height -= frame.size.height;
            break;
        case DGNumberBadgeViewAnchorBottomRight:
            innerOffset.width = -innerOffset.width;
            innerOffset.width -= frame.size.width;
            innerOffset.height = -innerOffset.height;
            innerOffset.height -= frame.size.height;
            break;
    }

    switch (self.anchor)
    {
        case DGNumberBadgeViewAnchorTopLeft:
            frame.origin.x = 0.f;
            frame.origin.y = 0.f;
            break;
        case DGNumberBadgeViewAnchorTop:
            frame.origin.x = (bounds.size.width + frame.size.width) / 2.f;
            frame.origin.y = 0.f;
            break;
        case DGNumberBadgeViewAnchorTopRight:
            frame.origin.x = bounds.size.width - frame.size.width;
            frame.origin.y = 0.f;
            break;
        case DGNumberBadgeViewAnchorCenterLeft:
            frame.origin.x = 0.f;
            frame.origin.y = (bounds.size.height + frame.size.height) / 2.f;
            break;
        case DGNumberBadgeViewAnchorCenter:
            frame.origin.x = (bounds.size.width + frame.size.width) / 2.f;
            frame.origin.y = (bounds.size.height + frame.size.height) / 2.f;
            break;
        case DGNumberBadgeViewAnchorCenterRight:
            frame.origin.x = bounds.size.width - frame.size.width;
            frame.origin.y = (bounds.size.height + frame.size.height) / 2.f;
            break;
        case DGNumberBadgeViewAnchorBottomLeft:
            frame.origin.x = 0.f;
            frame.origin.y = bounds.size.height - frame.size.height;
            break;
        case DGNumberBadgeViewAnchorBottom:
            frame.origin.x = (bounds.size.width + frame.size.width) / 2.f;
            frame.origin.y = bounds.size.height - frame.size.height;
            break;
        case DGNumberBadgeViewAnchorBottomRight:
            frame.origin.x = bounds.size.width - frame.size.width;
            frame.origin.y = bounds.size.height - frame.size.height;
            break;
    }
    
    frame.origin.x += innerOffset.width;
    frame.origin.y += innerOffset.height;
    
    self.frame = frame;
}

- (void)drawRect:(CGRect)rect
{
	CGRect viewBounds = self.bounds;
    
	CGContextRef curContext = UIGraphicsGetCurrentContext();
    
	NSString* numberString = [@(self.value) stringValue];
    
	CGSize numberSize = [numberString sizeWithFont:self.font];
    
    [self generateBadgePathForSize:numberSize];
    
	CGRect badgeRect = CGPathGetBoundingBox(lastBadgePath);
    
    BOOL shadow = self.shadow;
    CGSize shadowOffset = self.shadowOffset;
    CGFloat shadowBlur = self.shadowBlurSize;
    
	badgeRect.origin.x = 0;
	badgeRect.origin.y = 0;
    
    if (shadow)
    {
        if (shadowOffset.width < 0.f)
        {
            badgeRect.origin.x -= shadowOffset.width;
        }
        if (shadowOffset.height < 0.f)
        {
            badgeRect.origin.y -= shadowOffset.height;
        }
        badgeRect.origin.x += shadowBlur;
        badgeRect.origin.y += shadowBlur;
    }
    
	CGContextSaveGState( curContext );
	CGContextSetLineWidth( curContext, self.strokeWidth );
	CGContextSetStrokeColorWithColor(  curContext, self.strokeColor.CGColor  );
	CGContextSetFillColorWithColor( curContext, self.fillColor.CGColor );
    
	// Line stroke straddles the path, so we need to account for the outer portion
	badgeRect.size.width += ceilf( self.strokeWidth / 2 );
	badgeRect.size.height += ceilf( self.strokeWidth / 2 );
    
	CGPoint ctm;
    
	switch (self.alignment)
	{
		default:
		case UITextAlignmentCenter:
			ctm = CGPointMake( round((viewBounds.size.width - badgeRect.size.width)/2), round((viewBounds.size.height - badgeRect.size.height)/2) );
			break;
		case UITextAlignmentLeft:
			ctm = CGPointMake( 0, round((viewBounds.size.height - badgeRect.size.height)/2) );
			break;
		case UITextAlignmentRight:
			ctm = CGPointMake( (viewBounds.size.width - badgeRect.size.width), round((viewBounds.size.height - badgeRect.size.height)/2) );
			break;
	}
    
	CGContextTranslateCTM( curContext, ctm.x, ctm.y);
    
	if (shadow)
	{
		CGContextSaveGState( curContext );
        
		CGContextSetShadowWithColor( curContext, shadowOffset, shadowBlur, self.shadowColor.CGColor );
        
		CGContextBeginPath( curContext );
		CGContextAddPath( curContext, lastBadgePath );
		CGContextClosePath( curContext );
        
		CGContextDrawPath( curContext, kCGPathFillStroke );
		CGContextRestoreGState(curContext);
	}
    
	CGContextBeginPath( curContext );
	CGContextAddPath( curContext, lastBadgePath );
	CGContextClosePath( curContext );
	CGContextDrawPath( curContext, kCGPathFillStroke );
    
	if (self.shine)
	{
		CGContextBeginPath( curContext );
		CGContextAddPath( curContext, lastBadgePath );
		CGContextClosePath( curContext );
		CGContextClip(curContext);
        
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGFloat shinyColorGradient[8] = {1, 1, 1, 0.8, 1, 1, 1, 0};
		CGFloat shinyLocationGradient[2] = {0, 1};
		CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace,
                                                                     shinyColorGradient,
                                                                     shinyLocationGradient, 2);
        
		CGContextSaveGState(curContext);
		CGContextBeginPath(curContext);
		CGContextMoveToPoint(curContext, 0, 0);
        
		CGFloat shineStartY = badgeRect.size.height*0.25;
		CGFloat shineStopY = shineStartY + badgeRect.size.height*0.4;
        
		CGContextAddLineToPoint(curContext, 0, shineStartY);
		CGContextAddCurveToPoint(curContext, 0, shineStopY,
                                 badgeRect.size.width, shineStopY,
                                 badgeRect.size.width, shineStartY);
		CGContextAddLineToPoint(curContext, badgeRect.size.width, 0);
		CGContextClosePath(curContext);
		CGContextClip(curContext);
		CGContextDrawLinearGradient(curContext, gradient,
									CGPointMake(badgeRect.size.width / 2.0, 0),
									CGPointMake(badgeRect.size.width / 2.0, shineStopY),
									kCGGradientDrawsBeforeStartLocation);
		CGContextRestoreGState(curContext);
        
		CGColorSpaceRelease(colorSpace);
		CGGradientRelease(gradient);
        
	}
	CGContextRestoreGState( curContext );
    
	CGContextSaveGState( curContext );
	CGContextSetFillColorWithColor( curContext, self.textColor.CGColor );
    
	CGPoint textPt = CGPointMake( ctm.x + (badgeRect.size.width - numberSize.width)/2 , ctm.y + (badgeRect.size.height - numberSize.height)/2 );
    
	[numberString drawAtPoint:textPt withFont:self.font];
    
	CGContextRestoreGState( curContext );
}

- (CGPathRef)newBadgePathForTextSize:(CGSize)inSize
{
	CGFloat arcRadius = ceil((inSize.height+self.pad)/2.0);
    
	CGFloat badgeWidthAdjustment = inSize.width - inSize.height/2.0;
	CGFloat badgeWidth = 2.0*arcRadius;
    
	if ( badgeWidthAdjustment > 0.0 )
	{
		badgeWidth += badgeWidthAdjustment;
	}
    
	CGMutablePathRef badgePath = CGPathCreateMutable();
    
	CGPathMoveToPoint( badgePath, NULL, arcRadius, 0 );
	CGPathAddArc( badgePath, NULL, arcRadius, arcRadius, arcRadius, 3.0*M_PI_2, M_PI_2, YES);
	CGPathAddLineToPoint( badgePath, NULL, badgeWidth-arcRadius, 2.0*arcRadius);
	CGPathAddArc( badgePath, NULL, badgeWidth-arcRadius, arcRadius, arcRadius, M_PI_2, 3.0*M_PI_2, YES);
	CGPathAddLineToPoint( badgePath, NULL, arcRadius, 0 );
    
	return badgePath;
}

- (void)generateBadgePathForSize:(CGSize)size
{
    if (!CGSizeEqualToSize(size, lastBadgePathSize))
    {
        if (lastBadgePath)
        {
            CGPathRelease(lastBadgePath);
        }
        lastBadgePath = [self newBadgePathForTextSize:size];
        lastBadgePathSize = size;
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
	NSString* numberString = [@(self.value) stringValue];
    
	CGSize numberSize = [numberString sizeWithFont:self.font];
    
    [self generateBadgePathForSize:numberSize];
    
	CGRect badgeRect = CGPathGetBoundingBox(lastBadgePath);
    
	badgeRect.origin.x = 0;
	badgeRect.origin.y = 0;
    
	badgeRect.size.width += _strokeWidth;
	badgeRect.size.height += _strokeWidth;
    
    if (self.shadow)
    {
        CGSize shadowOffset = self.shadowOffset;
        badgeRect.size.width += fabsf(shadowOffset.width);
        badgeRect.size.height += fabsf(shadowOffset.height);
        
        CGFloat shadowBlur = self.shadowBlurSize;
        badgeRect.size.width += shadowBlur * 2.f;
        badgeRect.size.height += shadowBlur * 2.f;
    }
    
	return badgeRect.size;
}

- (void)layoutSubviews
{
	if (self.attachedToView)
    {
        [self repositionInMaster];
    }
}

@end