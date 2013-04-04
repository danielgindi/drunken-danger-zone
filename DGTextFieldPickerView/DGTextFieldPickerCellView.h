//
//  DGTextFieldPickerCellView.h
//  DGTextFieldPicker
//
//  Created by Daniel Cohen Gindi on 4/18/12.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGTextFieldPickerCellView : UIView <UIAppearance>

@property (nonatomic, strong) id        object;
@property (nonatomic, copy)   NSString *label;
@property (nonatomic, strong) UIFont   *font;
@property (nonatomic, assign) BOOL      selected;

@property (nonatomic, strong) UIColor *textColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *bgColor1 UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *bgColor2 UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *borderColor1 UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *borderColor2 UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *highlightedTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *highlightedBgColor1 UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *highlightedBgColor2 UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *highlightedBorderColor1 UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *highlightedBorderColor2 UI_APPEARANCE_SELECTOR;

@end
