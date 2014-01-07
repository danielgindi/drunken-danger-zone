//
//  DGPopupView.h
//  DGPopupView
//
//  Depends on DGKeyboardScrollHandler if you want it
//   to pop up inside a scroll view and respond to keyboard showing up
//
//  Created by Daniel Cohen Gindi on 10/31/12.
//  Copyright (c) 2012 AnyGym. All rights reserved.
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

typedef enum _DGPopupViewAnimationType
{
    DGPopupViewAnimationTypeNone,
    DGPopupViewAnimationTypePopup,
    DGPopupViewAnimationTypeTopBottom
} DGPopupViewAnimationType;

@class DGPopupView;
@protocol DGPopupViewDelegate <NSObject>

@optional

- (void)popupViewDidPopup:(DGPopupView *)popupView;
- (void)popupViewDidPopdown:(DGPopupView *)popupView;

@end

@interface DGPopupView : UIView

+ (instancetype)popupFromXib;

@property (nonatomic, assign) BOOL hasOverflay;
@property (nonatomic, assign) BOOL closesFromOverlay;
@property (nonatomic, assign) BOOL popupInsideScrollView;
@property (nonatomic, strong) UIColor *overlayColor;
@property (nonatomic, unsafe_unretained) id<DGPopupViewDelegate> popupDelegate;
@property (nonatomic, copy) void (^didPopupBlock)();
@property (nonatomic, copy) void (^didPopdownBlock)();

/* These are for when popupInsideScrollView is used, and there are textfields that need to be handled when the keyboard scrolls */
@property (nonatomic, unsafe_unretained) id<UITextFieldDelegate> popupTextFieldDelegate;
@property (nonatomic, unsafe_unretained) id<UITextViewDelegate> popupTextViewDelegate;

- (id)popupFromView:(UIView*)parentView;
- (id)popupFromView:(UIView*)parentView now:(BOOL)now;
- (id)popupFromView:(UIView*)parentView withPopupFrame:(CGRect)popupFrame;
- (id)popupFromView:(UIView*)parentView withPopupFrame:(CGRect)popupFrame animation:(DGPopupViewAnimationType)animation;
- (id)popupFromView:(UIView*)parentView withPopupFrame:(CGRect)popupFrame animation:(DGPopupViewAnimationType)animation now:(BOOL)now;
- (id)popupFromView:(UIView*)parentView animation:(DGPopupViewAnimationType)animation;
- (id)popupFromView:(UIView*)parentView animation:(DGPopupViewAnimationType)animation now:(BOOL)now;
- (id)popdown;
- (id)popdownShowNext:(BOOL)showNext; // If an override needed, override this!

- (CGRect)calculatePopupPositionInsideFrame:(CGRect)parentFrame;

- (void)attachAllFieldDelegatesToPopupsScrollView;

- (void)didFinishPopup;
- (void)didFinishPopdown;

#pragma mark - Utilities

- (UIImage *)gradientImageSized:(CGSize)size colors:(NSArray *)colors locations:(NSArray *)locations vertical:(BOOL)vertical;

@end
