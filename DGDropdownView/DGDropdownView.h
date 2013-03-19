//
//  DGDropdownView.h
//
//  Created by Daniel Cohen Gindi on 3/10/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDGDropdownViewHideNever ((NSTimeInterval)-1.0)

@interface DGDropdownView : UIView <UIAppearance>

@property (nonatomic, strong) NSArray * backgroundColors UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSArray * backgroundColorPositions UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor * bottomBorderColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat bottomBorderWidth UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIFont * titleFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor * titleTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor * titleShadowColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGSize titleShadowOffset UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) UITextAlignment titleTextAlignment UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIFont * detailFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor * detailTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor * detailShadowColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGSize detailShadowOffset UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) UITextAlignment detailTextAlignment UI_APPEARANCE_SELECTOR;

@property (nonatomic, assign) UIControlContentVerticalAlignment textVerticalAlignment UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) UIControlContentVerticalAlignment imageVerticalAlignment UI_APPEARANCE_SELECTOR;

@property (nonatomic, assign) UIEdgeInsets contentInsets UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat verticalTextPadding UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat imagePadding UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGSize maximumImageSize UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat animationDuration UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) BOOL imageOnTheRight UI_APPEARANCE_SELECTOR; // Seems like BOOL doesn't work with UI_APPEARANCE
@property (nonatomic, assign) BOOL alignImageToText UI_APPEARANCE_SELECTOR; // Seems like BOOL doesn't work with UI_APPEARANCE
@property (nonatomic, assign) CGFloat maxHeight UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat minHeight UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) BOOL reduceImageSizeOnBothSides UI_APPEARANCE_SELECTOR; // Seems like BOOL doesn't work with UI_APPEARANCE

@property (nonatomic, strong) NSString * title UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSString * detail UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIImage * image UI_APPEARANCE_SELECTOR;

+ (DGDropdownView*)visibleDropdownInView:(UIView*)view;

+ (DGDropdownView*)dropdownViewWithTitle:(NSString*)title
                                  detail:(NSString*)detail
                                   image:(UIImage*)image;

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
                                 title:(NSString*)title
                                detail:(NSString*)detail
                                 image:(UIImage*)image;

+ (DGDropdownView *)showDropdownInView:(UIView *)view
                                 title:(NSString*)title
                                detail:(NSString*)detail
                                 image:(UIImage*)image
                              animated:(BOOL)animated;

+ (DGDropdownView *)showDropdownInView:(UIView *)view
                                 title:(NSString*)title
                                detail:(NSString*)detail
                                 image:(UIImage*)image
                              animated:(BOOL)animated
                             hideAfter:(NSTimeInterval)hideAfter;

+ (DGDropdownView *)showDropdownInView:(UIView *)view
                                 title:(NSString*)title
                                detail:(NSString*)detail
                                 image:(UIImage*)image
                             hideAfter:(NSTimeInterval)hideAfter;

+ (DGDropdownView *)showDropdownWithTitle:(NSString*)title
                                   detail:(NSString*)detail
                                    image:(UIImage*)image
                                hideAfter:(NSTimeInterval)hideAfter;

+ (DGDropdownView *)showDropdownWithTitle:(NSString*)title
                                   detail:(NSString*)detail
                                    image:(UIImage*)image;

+ (DGDropdownView *)showDropdownWithTitle:(NSString*)title
                                   detail:(NSString*)detail
                                    image:(UIImage*)image
                                 animated:(BOOL)animated;

+ (DGDropdownView *)showDropdownWithTitle:(NSString*)title
                                   detail:(NSString*)detail
                                    image:(UIImage*)image
                                 animated:(BOOL)animated
                                hideAfter:(NSTimeInterval)hideAfter;

- (DGDropdownView *)hideDropDown;
- (DGDropdownView *)hideDropDownAnimated:(BOOL)animated;

+ (DGDropdownView *)hideDropDownInView:(UIView*)view;
+ (DGDropdownView *)hideDropDownInView:(UIView*)view animated:(BOOL)animated;

+ (DGDropdownView *)hideDropDown;
+ (DGDropdownView *)hideDropDownAnimated:(BOOL)animated;

- (DGDropdownView*)setTouchUpInsideTarget:(id)target action:(SEL)action;

@end
