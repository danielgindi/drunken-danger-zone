//
//  DGPickerButton.h
//  DGPickerButton
//
//  Created by Daniel Cohen Gindi on 2/7/13.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
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
