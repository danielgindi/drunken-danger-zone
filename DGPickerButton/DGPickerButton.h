//
//  DGPickerButton.h
//  DGPickerButton
//
//  Created by Daniel Cohen Gindi on 2/7/13.
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

#import <UIKit/UIKit.h>

@class DGPickerButton;

@protocol DGPickerButtonDelegate <NSObject>

@optional
- (void)pickerButtonDidBecomeFirstResponder:(DGPickerButton *)button;
- (void)pickerButtonPickerValueChanged:(DGPickerButton *)button;

@end

@interface DGPickerButton : UIButton <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) IBOutlet id<DGPickerButtonDelegate> delegate;
@property (nonatomic, assign) BOOL isPicker;
@property (nonatomic, assign) BOOL isDatePicker;
@property (nonatomic, strong) NSDictionary *pickerOptions;
@property (nonatomic, strong) id pickerSelectedKey;
@property (nonatomic, readonly) NSString *pickerSelectedValue;
@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) IBOutlet UIDatePicker *datePickerView;

- (void)setPickerOptions:(NSDictionary *)pickerOptions withSortedKeys:(NSArray *)keys;
- (void)setPickerOptions:(NSArray *)pickerOptions sortArray:(BOOL)sort;

// Override
@property (readwrite, strong) UIView *inputAccessoryView;

@end
