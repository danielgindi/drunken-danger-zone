//
//  DGSlideMenuViewController.h
//  DGSlideMenuViewController
//
//  Created by Daniel Cohen Gindi on 11/23/12.
//  Copyright (c) 2012 danielgindi@gmail.com. All rights reserved.
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

@class DGSlideMenuViewController;
@protocol DGSlideMenuViewControllerDelegate <NSObject>

@optional
- (BOOL)slideMenuViewController:(DGSlideMenuViewController *)vc selectedMenuAt:(NSString *)identifier fromGroup:(NSString *)groupIdentifier;
- (UIView *)slideMenuViewController:(DGSlideMenuViewController *)vc customViewForSectionHeader:(NSString *)sectionKey;
- (UITableViewCell *)slideMenuViewController:(DGSlideMenuViewController *)vc customTableCellForItem:(NSString *)itemKey inSection:(NSString *)sectionKey withTitle:(NSString *)title inTableView:(UITableView*)tableView;

@end

@interface DGSlideMenuViewController : UIViewController <UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id<DGSlideMenuViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL retainSelection;
@property (nonatomic, assign) CGFloat sectionHeaderHeight UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat sectionHeaderPaddingLeft UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat sectionHeaderFontSize UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *sectionHeaderTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *sectionHeaderTopColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *sectionHeaderBottomColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *tableBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIImage *tableBackgroundImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIView *tableBackgroundView UI_APPEARANCE_SELECTOR;

- (id)initWithRootViewController:(UIViewController *)rootViewController;

- (BOOL)hasGroup:(NSString *)identifier;

- (void)switchToViewController:(UIViewController *)viewController;
- (void)switchToViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (void)addGroupWithTitle:(NSString *)title withIdentifier:(NSString *)identifier;
- (void)addGroupWithTitle:(NSString *)title withIdentifier:(NSString *)identifier atIndex:(NSInteger)index;

- (void)addItemWithTitle:(NSString *)title andViewController:(UIViewController *)viewController withIdentifier:(NSString *)identifier andIcon:(UIImage *)icon andSelectedIcon:(UIImage *)selectedIcon andTitleColor:(UIColor *)titleColor andSelectedTitleColor:(UIColor *)selectedTitleColor andTitleFont:(UIFont *)titleFont inGroup:(NSString *)groupIdentifier;
- (void)addItemWithTitle:(NSString *)title andViewController:(UIViewController *)viewController withIdentifier:(NSString *)identifier andIcon:(UIImage *)icon andSelectedIcon:(UIImage *)selectedIcon andTitleColor:(UIColor *)titleColor andSelectedTitleColor:(UIColor *)selectedTitleColor andTitleFont:(UIFont *)titleFont inGroup:(NSString *)groupIdentifier atIndex:(NSInteger)index;

- (void)setTitle:(NSString *)title forItem:(NSString *)identifier inGroup:(NSString *)groupIdentifier;
- (void)setViewController:(UIViewController *)viewController forItem:(NSString *)identifier inGroup:(NSString *)groupIdentifier;

- (NSInteger)indexOfItem:(NSString *)identifier inGroup:(NSString *)groupIdentifier;

- (void)removeGroup:(NSString *)identifier;
- (void)removeItem:(NSString *)item inGroup:(NSString *)group;

- (void)highlightItem:(NSString *)item inGroup:(NSString *)group;
- (void)highlightItem:(NSString *)item inGroup:(NSString *)group moveToViewController:(BOOL)moveToViewController animated:(BOOL)animated;

- (NSString *)highlightedGroup;
- (NSString *)highlightedItem;
- (UIViewController *)selectedViewController;

- (void)tapGestureRecognized:(UIPanGestureRecognizer *)gesture;
- (void)panGestureRecognized:(UIPanGestureRecognizer *)gesture;

- (void)slideOut;

@end
