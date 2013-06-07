//
//  DGTextField.h
//  DGTextField
//
//  Created by Daniel Cohen Gindi on 10/19/12.
//  Copyright (c) 2012 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import <UIKit/UIKit.h>

@interface DGTextField : UITextField <UIAppearance>

@property (nonatomic, strong) UIColor *placeholderColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) UIEdgeInsets contentInsets UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) UIEdgeInsets clearButtonInsets UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) UITextDirection textFieldUIDirection;

- (BOOL)isRtl;

@end
