//
//  DGTextFieldPickerView.h
//  DGTextFieldPicker
//
//  Created by Daniel Cohen Gindi on 4/18/12.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DGTextFieldPickerView, DGTextFieldPickerCellView;

@protocol DGTextFieldPickerViewDelegate <NSObject>
@required
- (void)textFieldPickerView:(DGTextFieldPickerView*)textField showSearchTable:(BOOL)show;
- (BOOL)textFieldPickerView:(DGTextFieldPickerView*)textField search:(NSString*)keywords;
- (BOOL)textFieldPickerViewHasSearchResults:(DGTextFieldPickerView*)textField;

@optional
- (NSString*)textFieldPickerView:(DGTextFieldPickerView*)textField labelForObject:(id)object;
- (void)textFieldPickerViewDidResize:(DGTextFieldPickerView*)textField;
- (void)textFieldPickerView:(DGTextFieldPickerView*)textField didAddCellAtIndex:(NSUInteger)index;
- (void)textFieldPickerView:(DGTextFieldPickerView*)textField didRemoveCellAtIndex:(NSUInteger)index;
- (void)textFieldPickerView:(DGTextFieldPickerView*)textField returnRequestedWithText:(NSString*)text;
- (void)textFieldPickerViewDidBeginEditing:(DGTextFieldPickerView*)textField;
- (void)textFieldPickerViewDidEndEditing:(DGTextFieldPickerView*)textField;
@end

@interface DGTextFieldPickerView : UITextField <UITextFieldDelegate, UIAppearance>

@property (nonatomic, weak)                 id<DGTextFieldPickerViewDelegate> searchDelegate;
@property (nonatomic, assign, readonly)     BOOL hasText;
@property (nonatomic, assign)               BOOL searchesAutomatically;
@property (nonatomic, strong, readonly)     NSArray *cellViews;
@property (nonatomic, strong, readonly)     NSArray *cells;
@property (nonatomic, strong)               DGTextFieldPickerCellView* selectedCell;
@property (nonatomic, readonly)             int lineCount;
@property (nonatomic, assign) CGFloat minimumHeight;
@property (nonatomic, assign) CGFloat cellXSpacing UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *placeholderColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) UIEdgeInsets contentInsets UI_APPEARANCE_SELECTOR;

- (void)search;
- (void)showSearchResults:(BOOL)show;

- (NSString*)searchText;

- (void)addCellWithObject:(id)object;
- (void)removeCellWithObject:(id)object;
- (void)removeAllCells;
- (void)removeSelectedCell;
- (void)scrollToVisibleLine:(BOOL)animated;
- (void)scrollToEditingLine:(BOOL)animated;

// Cell Styling

@property (nonatomic, strong) UIColor *cellTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *cellBgColor1 UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *cellBgColor2 UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *cellBorderColor1 UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *cellBorderColor2 UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *cellHighlightedTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *cellHighlightedBgColor1 UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *cellHighlightedBgColor2 UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *cellHighlightedBorderColor1 UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *cellHighlightedBorderColor2 UI_APPEARANCE_SELECTOR;

@end
