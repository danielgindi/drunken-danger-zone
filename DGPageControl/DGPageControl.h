//
//  DGPageControl.h
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

#import <Foundation/Foundation.h>

typedef enum _DGPageControlStyle
{
	DGPageControlStyleOnFullOffFull     = 0,
	DGPageControlStyleOnFullOffEmpty	= 1,
	DGPageControlStyleOnEmptyOffFull	= 2,
	DGPageControlStyleOnEmptyOffEmpty	= 3,
} DGPageControlStyle;

@interface DGPageControl : UIControl

/*! @property numberOfPages 
    @brief How many pages to show? */
@property (nonatomic, assign) NSInteger numberOfPages;

/*! @property currentPage
    @brief The current selected page, 0-based */
@property (nonatomic, assign) NSInteger currentPage;

/*! @property hidesForSinglePage
    @brief This property controls the hidden property, setting to YES when there's 1 or less pages, and to NO when there's more than 1. */
@property (nonatomic, assign) BOOL hidesForSinglePage;

/*! @property defersCurrentPageDisplay
    @brief Equivalent of Apple's defersCurrentPageDisplay. Will prevent redraw of the PageControl when currentPage changes, until updateCurrentPageDisplay is sent to the PageControle */
@property (nonatomic, assign) BOOL defersCurrentPageDisplay;

/*! @property style
    @brief The style for the pager dots 
           Default is On-Full, Off-Full */
@property (nonatomic, assign) DGPageControlStyle style;

/*! @property onColor
    @brief The color for pager dots, in ON state */
@property (nonatomic, strong) UIColor *onColor;

/*! @property offColor
    @brief The color for pager dots, in OFF state */
@property (nonatomic, strong) UIColor *offColor;

/*! @property dotDiameter
    @brief The diameter for the pager dots 
            Default is 5.f */
@property (nonatomic, assign) CGFloat dotDiameter;

/*! @property dotSpacing
    @brief The spacing between the pager dots
           Default is 11.f */
@property (nonatomic, assign) CGFloat dotSpacing;

/*! @property horizontalPadding
    @brief Padding for the width of the control, both sides.
           Default is 22.f */
@property (nonatomic, assign) CGFloat horizontalPadding;

/*! @property verticalPadding
    @brief Padding for the height of the control, both sides.
           Default is 2.f */
@property (nonatomic, assign) CGFloat verticalPadding;

/*! @property maxHeight
    @brief Maximum height for the control.
           Default is 44.f */
@property (nonatomic, assign) CGFloat maxHeight;

/*! @property automaticControlSize
    @brief Should we control the PageControl's size like Apple do?
           Set to NO if you want it to be a custom size (i.e. with a transparent background, having the dots centered...)
           Default is YES */
@property (nonatomic, assign) BOOL automaticControlSize;

/*! Initialize with a specific style
    @param style the control style */
- (id)initWithStyle:(DGPageControlStyle)style;

/*! Request the correct size for a specific page count
 @param pageCount the count of pages you want to inspect */
- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount;

/*! Equivalent of Apple's updateCurrentPageDisplay. Triggers a redraw in case defersCurrentPageDisplay was set to YES  */
- (void)updateCurrentPageDisplay;

@end

