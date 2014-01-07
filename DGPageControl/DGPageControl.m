//
//  DGPageControl.m
//  DGPageControl
//
//  Created by Daniel Cohen Gindi on 11/7/12.
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

#import "DGPageControl.h"

@implementation DGPageControl

- (void)DGPageControl_initialize
{
    _dotDiameter = 5.f; // Apple's value
    _dotSpacing = 11.f; // Apple's value
    _automaticControlSize = YES; // Apple's behaviour
    _maxHeight = 44.f; // Apple's value
    _horizontalPadding = 22.f; // Apple's value
    _verticalPadding = 2.f; // Apple's value
}

- (id)initWithStyle:(DGPageControlStyle)style
{
	self = [self initWithFrame:CGRectZero];
    if (self)
    {
        _style = style;
    }
	return self;
}

- (id)init
{
	self = [self initWithFrame:CGRectZero];
    if (self)
    {
        
    }
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectZero];
	if (self)
	{
        [self DGPageControl_initialize];
		self.backgroundColor = UIColor.clearColor;
	}
	return self;
}

- (void)drawRect:(CGRect)rect 
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGContextSetAllowsAntialiasing(context, TRUE);
	
	CGFloat diameter = self.dotDiameter;
	CGFloat space = self.dotSpacing;
	
	CGRect currentBounds = self.bounds;
	CGFloat dotsWidth = self.numberOfPages * diameter;
    dotsWidth += MAX(0, self.numberOfPages - 1) * space;
    
	CGFloat x = currentBounds.origin.x + currentBounds.size.width / 2.f - dotsWidth / 2;
	CGFloat y = currentBounds.origin.y + currentBounds.size.height / 2.f - diameter / 2;
	
	UIColor *drawOnColor = _onColor ? _onColor : [UIColor colorWithWhite:1.0f alpha:1.0f];
	UIColor *drawOffColor = _offColor ? _offColor : [UIColor colorWithWhite:1.0f alpha:0.3f];
	
	CGRect dotRect;
	for (int i = 0; i < _numberOfPages; i++)
	{
        dotRect = CGRectMake(x, y, diameter, diameter);
		
		if (i == _currentPage)
		{
			if (_style == DGPageControlStyleOnFullOffFull || _style == DGPageControlStyleOnFullOffEmpty)
			{
				CGContextSetFillColorWithColor(context, drawOnColor.CGColor);
				CGContextFillEllipseInRect(context, CGRectInset(dotRect, -0.5f, -0.5f));
			}
			else
			{
				CGContextSetStrokeColorWithColor(context, drawOnColor.CGColor);
				CGContextStrokeEllipseInRect(context, dotRect);
			}
		}
		else
		{
			if (_style == DGPageControlStyleOnEmptyOffEmpty || _style == DGPageControlStyleOnFullOffEmpty)
			{
				CGContextSetStrokeColorWithColor(context, drawOffColor.CGColor);
				CGContextStrokeEllipseInRect(context, dotRect);
			}
			else
			{
				CGContextSetFillColorWithColor(context, drawOffColor.CGColor);
				CGContextFillEllipseInRect(context, CGRectInset(dotRect, -0.5f, -0.5f));
			}
		}
		
		x += diameter + space;
	}
	
	CGContextRestoreGState(context);
}

#pragma mark - Accessors

- (void)setCurrentPage:(NSInteger)pageNumber
{
	if (_currentPage == pageNumber) return;
	
	_currentPage = MIN(MAX(0, pageNumber), _numberOfPages - 1);
	
	if (!self.defersCurrentPageDisplay)
    {
        [self setNeedsDisplay];
    }
}

- (void)setNumberOfPages:(NSInteger)numOfPages
{
	_numberOfPages = MAX(0, numOfPages);
	_currentPage = MIN(MAX(0, _currentPage), _numberOfPages - 1);
	
    if (_automaticControlSize)
    {
        // Size may have changed, and we need to keep the constraints...
        self.bounds = self.bounds;
    }
	
	[self setNeedsDisplay];
	
    self.hidden = _hidesForSinglePage && (numOfPages < 2);
}

- (void)setHidesForSinglePage:(BOOL)hide
{
	_hidesForSinglePage = hide;
	
    self.hidden = _hidesForSinglePage && (_numberOfPages < 2);
}

- (void)setDefersCurrentPageDisplay:(BOOL)defers
{
	_defersCurrentPageDisplay = defers;
}

- (void)setType:(DGPageControlStyle)style
{
	_style = style;
	
	[self setNeedsDisplay];
}

- (void)setOnColor:(UIColor *)onColor
{
	_onColor = onColor;
	
	[self setNeedsDisplay];
}

- (void)setOffColor:(UIColor *)offColor
{
	_offColor = offColor;
	
	[self setNeedsDisplay];
}

- (void)setDotDiameter:(CGFloat)dotDiameter
{
	_dotDiameter = dotDiameter;
	
    if (_automaticControlSize)
    {
        // Size may have changed, and we need to keep the constraints...
        self.bounds = self.bounds;
    }
	
	[self setNeedsDisplay];
}

- (void)setDotSpacing:(CGFloat)dotSpacing
{
	_dotSpacing = dotSpacing;
	
    if (_automaticControlSize)
    {
        // Size may have changed, and we need to keep the constraints...
        self.bounds = self.bounds;
    }
	
	[self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame
{
    if (_automaticControlSize)
    {
        frame.size = [self sizeForNumberOfPages:_numberOfPages];
    }
    [super setFrame:frame];
}

- (void)setBounds:(CGRect)bounds
{
    if (_automaticControlSize)
    {
        bounds.size = [self sizeForNumberOfPages: _numberOfPages];
    }
    [super setBounds:bounds];
}

- (void)setAutomaticControlSize:(BOOL)automaticControlSize
{
    _automaticControlSize = automaticControlSize;
    
    if (automaticControlSize)
    {
        self.bounds = self.bounds;
    }
}

#pragma mark - UIPageControl methods

- (void)updateCurrentPageDisplay
{
	if (!self.defersCurrentPageDisplay) return;
	
	[self setNeedsDisplay];
}

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount
{
    CGFloat diameter = self.dotDiameter;
	return CGSizeMake(pageCount * diameter + (pageCount - 1) * self.dotSpacing + self.horizontalPadding * 2.f, MAX(self.maxHeight, diameter + self.verticalPadding * 2.f));
}

#pragma mark - Touches handlers

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *theTouch = [touches anyObject];
	CGPoint touchLocation = [theTouch locationInView: self];
	
	if (touchLocation.x < (self.bounds.size.width / 2.f))
    {
		self.currentPage = MAX(self.currentPage - 1, 0);
    }
	else
    {
		self.currentPage = MIN(self.currentPage + 1, self.numberOfPages - 1);
    }
	
	[self sendActionsForControlEvents: UIControlEventValueChanged];
}

@end