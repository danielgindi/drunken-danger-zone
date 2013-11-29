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

#pragma mark - Utilities

- (UIImage *)gradientImageSized:(CGSize)size colors:(NSArray *)colors locations:(NSArray *)locations vertical:(BOOL)vertical;

@end
