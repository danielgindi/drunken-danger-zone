//
//  DGPickerButton.m
//  DGPickerButton
//
//  Created by Daniel Cohen Gindi on 2/7/13.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGPickerButton.h"

@implementation DGPickerButton 
{
    UIPickerView *_pickerView;
    UIDatePicker *_datePickerView;
    NSArray *pickerOptionKeys;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self addTarget:self action:@selector(resignOrBecomeFirstResponderAndSelection:) forControlEvents:UIControlEventTouchUpInside];
        _isPicker = YES;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addTarget:self action:@selector(resignOrBecomeFirstResponderAndSelection:) forControlEvents:UIControlEventTouchUpInside];
        _isPicker = YES;
    }
    return self;
}

- (void)setPickerOptions:(NSDictionary *)pickerOptions
{
    [self setPickerOptions:pickerOptions withSortedKeys:nil];
}

- (void)setPickerOptions:(NSDictionary *)pickerOptions withSortedKeys:(NSArray *)keys
{
    _pickerOptions = pickerOptions;
    
    if (!keys)
    {
        keys = [_pickerOptions.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [_pickerOptions[obj1] compare:_pickerOptions[obj2]];
        }];
    }
    pickerOptionKeys = keys;
    
    [self.pickerView reloadAllComponents];
    self.pickerSelectedKey = self.pickerSelectedKey; // Re-set selected row
}

- (void)setPickerOptions:(NSArray *)pickerOptions sortArray:(BOOL)sort
{
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    for (int j=0, len=pickerOptions.count; j<len; j++)
    {
        options[@(j)] = pickerOptions[j];
    }
    NSMutableArray *keys = nil;
    if (!sort)
    {
        keys = [[NSMutableArray alloc] init];
        for (int j=0, len=pickerOptions.count; j<len; j++)
        {
            [keys addObject:@(j)];
        }
    }
    [self setPickerOptions:options withSortedKeys:keys];
}

- (void)setPickerSelectedKey:(id)pickerSelectedKey
{
    _pickerSelectedKey = pickerSelectedKey;
    if (self.pickerSelectedKey)
    {
        NSInteger index = [pickerOptionKeys indexOfObject:_pickerSelectedKey];
        if (index>=0)
        {
            [self.pickerView selectRow:index inComponent:0 animated:NO];
        }
    }
}

- (NSString *)pickerSelectedValue
{
    return _pickerOptions[self.pickerSelectedKey];
}

- (BOOL)canBecomeFirstResponder
{
    if (_isDatePicker || _isPicker)
    {
        return YES;
    }
    return [super canBecomeFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    if (_isDatePicker || _isPicker)
    {
        BOOL returnValue = [super becomeFirstResponder];
        if (returnValue)
        {
            if (_delegate && [_delegate respondsToSelector:@selector(pickerButtonDidBecomeFirstResponder:)])
            {
                [_delegate pickerButtonDidBecomeFirstResponder:self];
            }
            self.selected = YES;
        }
        return returnValue;
    }
    return [super becomeFirstResponder];
}

- (UIView *)inputView
{
    if (_isDatePicker || _isPicker)
    {
        if (_isDatePicker)
        {
            return self.datePickerView;
        }
        else
        {
            self.pickerSelectedKey = self.pickerSelectedKey; // Re-set selected row
            return self.pickerView;
        }
    }
    return nil;
}

- (BOOL)resignFirstResponder
{
    BOOL returnValue = [super resignFirstResponder];
    if (returnValue)
    {
        self.selected = NO;
    }
    return returnValue;
}

- (void)resignOrBecomeFirstResponderAndSelection:(id)sender
{
    if ([self isFirstResponder])
    {
        [self resignFirstResponder];
    }
    else
    {
        [self becomeFirstResponder];
    }
}

- (void)setPickerView:(UIPickerView *)pickerView
{
    _pickerView = pickerView;
}

- (UIPickerView *)pickerView
{
    if (!_pickerView)
    {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        _pickerView.showsSelectionIndicator = YES;
    }
    return _pickerView;
}

- (void)setDatePickerView:(UIDatePicker *)datePickerView
{
    _datePickerView = datePickerView;
}

- (UIDatePicker *)datePickerView
{
    if (!_datePickerView)
    {
        _datePickerView = [[UIDatePicker alloc] init];
        [_datePickerView addTarget:self action:@selector(datePickerViewValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _datePickerView;
}

#pragma mark - Actions

- (void)datePickerViewValueChanged:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(pickerButtonPickerValueChanged:)])
    {
        [_delegate pickerButtonPickerValueChanged:self];
    }
}

#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerOptions.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerOptions[pickerOptionKeys[row]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _pickerSelectedKey = pickerOptionKeys[row];
    if (_delegate && [_delegate respondsToSelector:@selector(pickerButtonPickerValueChanged:)])
    {
        [_delegate pickerButtonPickerValueChanged:self];
    }
}

@end
