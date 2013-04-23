//
//  DGSlideMenuViewController.h
//  DGSlideMenuViewController
//
//  Created by Daniel Cohen Gindi on 11/23/12.
//  Copyright (c) 2012 danielgindi@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DGSlideMenuViewController;
@protocol DGSlideMenuViewControllerDelegate <NSObject>

@optional
- (BOOL)slideMenuViewController:(DGSlideMenuViewController*)vc selectedMenuAt:(NSString*)identifier fromGroup:(NSString*)groupIdentifier;

@end

@interface DGSlideMenuViewController : UIViewController <UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id<DGSlideMenuViewControllerDelegate> delegate;

- (id)initWithRootViewController:(UIViewController*)rootViewController;

- (BOOL)hasGroup:(NSString*)identifier;

- (void)switchToViewController:(UIViewController*)viewController;
- (void)switchToViewController:(UIViewController*)viewController animated:(BOOL)animated;

- (void)addGroupWithTitle:(NSString*)title withIdentifier:(NSString*)identifier;
- (void)addGroupWithTitle:(NSString*)title withIdentifier:(NSString*)identifier atIndex:(NSInteger)index;

- (void)addItemWithTitle:(NSString*)title andViewController:(UIViewController*)viewController withIdentifier:(NSString*)identifier andIcon:(UIImage*)icon andSelectedIcon:(UIImage*)selectedIcon andTitleColor:(UIColor*)titleColor andSelectedTitleColor:(UIColor*)selectedTitleColor andTitleFont:(UIFont*)titleFont inGroup:(NSString*)groupIdentifier;
- (void)addItemWithTitle:(NSString*)title andViewController:(UIViewController*)viewController withIdentifier:(NSString*)identifier andIcon:(UIImage*)icon andSelectedIcon:(UIImage*)selectedIcon andTitleColor:(UIColor*)titleColor andSelectedTitleColor:(UIColor*)selectedTitleColor andTitleFont:(UIFont*)titleFont inGroup:(NSString*)groupIdentifier atIndex:(NSInteger)index;

- (void)setTitle:(NSString*)title forItem:(NSString*)identifier inGroup:(NSString*)groupIdentifier;
- (void)setViewController:(UIViewController*)viewController forItem:(NSString*)identifier inGroup:(NSString*)groupIdentifier;

- (void)removeGroup:(NSString*)identifier;
- (void)removeItem:(NSString*)item inGroup:(NSString*)group;

- (void)highlightItem:(NSString*)item inGroup:(NSString*)group;
- (void)highlightItem:(NSString*)item inGroup:(NSString*)group moveToViewController:(BOOL)moveToViewController animated:(BOOL)animated;

- (void)doSlideOut;

- (NSString*)highlightedGroup;
- (NSString*)highlightedItem;
- (UIViewController*)selectedViewController;

@end
