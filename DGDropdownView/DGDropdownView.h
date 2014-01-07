//
//  DGDropdownView.h
//  DGDropdownView
//
//  Created by Daniel Cohen Gindi on 3/10/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
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

#define kDGDropdownViewHideNever ((NSTimeInterval)-1.0)

@interface DGDropdownView : UIView <UIAppearance>

@property (nonatomic, strong) NSArray *backgroundColors UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSArray *backgroundColorPositions UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *bottomBorderColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat bottomBorderWidth UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIFont *titleFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *titleTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *titleShadowColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGSize titleShadowOffset UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSTextAlignment titleTextAlignment UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIFont *detailFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *detailTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *detailShadowColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGSize detailShadowOffset UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSTextAlignment detailTextAlignment UI_APPEARANCE_SELECTOR;

@property (nonatomic, assign) UIControlContentVerticalAlignment textVerticalAlignment UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) UIControlContentVerticalAlignment imageVerticalAlignment UI_APPEARANCE_SELECTOR;

@property (nonatomic, assign) UIEdgeInsets contentInsets UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat verticalTextPadding UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat imagePadding UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGSize maximumImageSize UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat animationDuration UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) int imageOnTheRight UI_APPEARANCE_SELECTOR; // Seems like BOOL doesn't work with UI_APPEARANCE
@property (nonatomic, assign) int alignImageToText UI_APPEARANCE_SELECTOR; // Seems like BOOL doesn't work with UI_APPEARANCE
@property (nonatomic, assign) CGFloat maxHeight UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat minHeight UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) int reduceImageSizeOnBothSides UI_APPEARANCE_SELECTOR; // Seems like BOOL doesn't work with UI_APPEARANCE

@property (nonatomic, strong) NSString *title UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSString *detail UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIImage *image UI_APPEARANCE_SELECTOR;

+ (DGDropdownView *)visibleDropdownInView:(UIView *)view;

+ (DGDropdownView *)dropdownViewWithTitle:(NSString *)title
                                  detail:(NSString *)detail
                                   image:(UIImage *)image;

- (DGDropdownView *)showInView:(UIView *)view;
- (DGDropdownView *)showInView:(UIView *)view
                      animated:(BOOL)animated;
- (DGDropdownView *)showInView:(UIView *)view
                      animated:(BOOL)animated
                     hideAfter:(NSTimeInterval)hideAfter;
- (DGDropdownView *)showInView:(UIView *)view
                     hideAfter:(NSTimeInterval)hideAfter;

- (DGDropdownView *)show;
- (DGDropdownView *)showAnimated:(BOOL)animated;
- (DGDropdownView *)showAnimated:(BOOL)animated
                       hideAfter:(NSTimeInterval)hideAfter;
- (DGDropdownView *)showHideAfter:(NSTimeInterval)hideAfter;

+ (DGDropdownView *)showDropdownInView:(UIView *)view
                                 title:(NSString *)title
                                detail:(NSString *)detail
                                 image:(UIImage *)image;

+ (DGDropdownView *)showDropdownInView:(UIView *)view
                                 title:(NSString *)title
                                detail:(NSString *)detail
                                 image:(UIImage *)image
                              animated:(BOOL)animated;

+ (DGDropdownView *)showDropdownInView:(UIView *)view
                                 title:(NSString *)title
                                detail:(NSString *)detail
                                 image:(UIImage *)image
                              animated:(BOOL)animated
                             hideAfter:(NSTimeInterval)hideAfter;

+ (DGDropdownView *)showDropdownInView:(UIView *)view
                                 title:(NSString *)title
                                detail:(NSString *)detail
                                 image:(UIImage *)image
                             hideAfter:(NSTimeInterval)hideAfter;

+ (DGDropdownView *)showDropdownWithTitle:(NSString *)title
                                   detail:(NSString *)detail
                                    image:(UIImage *)image
                                hideAfter:(NSTimeInterval)hideAfter;

+ (DGDropdownView *)showDropdownWithTitle:(NSString *)title
                                   detail:(NSString *)detail
                                    image:(UIImage *)image;

+ (DGDropdownView *)showDropdownWithTitle:(NSString *)title
                                   detail:(NSString *)detail
                                    image:(UIImage *)image
                                 animated:(BOOL)animated;

+ (DGDropdownView *)showDropdownWithTitle:(NSString *)title
                                   detail:(NSString *)detail
                                    image:(UIImage *)image
                                 animated:(BOOL)animated
                                hideAfter:(NSTimeInterval)hideAfter;

- (DGDropdownView *)hideDropDown;
- (DGDropdownView *)hideDropDownAnimated:(BOOL)animated;

+ (DGDropdownView *)hideDropDownInView:(UIView *)view;
+ (DGDropdownView *)hideDropDownInView:(UIView *)view animated:(BOOL)animated;

+ (DGDropdownView *)hideDropDown;
+ (DGDropdownView *)hideDropDownAnimated:(BOOL)animated;

- (DGDropdownView *)setTouchUpInsideTarget:(id)target action:(SEL)action;

@end
