//
//  DGInputAccessoryToolbar.m
//  DGInputAccessoryToolbar
//
//  Created by Daniel Cohen Gindi on 2/7/13.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGInputAccessoryToolbar.h"

#ifndef IS_IOS7_OR_GREATER
#define IS_IOS7_OR_GREATER                  ([UIDevice.currentDevice.systemVersion compare:@"7.0" options:NSNumericSearch] >= NSOrderedSame)
#endif

@interface DGInputAccessoryToolbar ()
@end

@implementation DGInputAccessoryToolbar
{
    id actionTarget;
    SEL prevActionSelector, nextActionSelector, doneActionSelector;
    UISegmentedControl *segmented;
    UIBarButtonItem *doneButton;
}

- (void)initialize_DGInputAccessoryToolbar
{
    CGRect rect = self.frame;
    rect.size.height = 44.f;
    self.frame = rect;
    
    if (IS_IOS7_OR_GREATER)
    {
        self.barStyle = UIBarStyleDefault;
        self.tintColor = UIColor.blackColor;
    }
    else
    {
        self.barStyle = UIBarStyleBlackTranslucent;
        self.translucent = YES;
        //self.tintColor = UIColor.darkGrayColor;
    }
    
    NSString *prevString, *nextString;
    
    NSString *localeId = NSBundle.mainBundle.preferredLocalizations[0];
    if ([localeId hasPrefix:@"he"])
    {
        prevString = @"הקודם";
        nextString = @"הבא";
    }
    else
    {
        prevString = @"Previous";
        nextString = @"Next";
    }
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    if (prevActionSelector || nextActionSelector)
    {
        segmented = [[UISegmentedControl alloc] initWithItems:((prevActionSelector&&nextActionSelector) ? @[prevString,nextString] : (prevActionSelector ? @[prevString] : @[nextString]))];
        [segmented addTarget:self action:@selector(segmentedControlChangedValued:) forControlEvents:UIControlEventValueChanged];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
        segmented.segmentedControlStyle = UISegmentedControlStyleBar;
#endif
        if (IS_IOS7_OR_GREATER)
        {
            // Color will come from tint automatically
        }
        else
        {
            segmented.tintColor = [UIColor darkGrayColor];
        }
        
        segmented.momentary = YES;
        [items addObject:[[UIBarButtonItem alloc] initWithCustomView:segmented]];
    }
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:actionTarget action:doneActionSelector];
    
    [items addObject:flexSpace];
    [items addObject:doneButton];
    [self setItems:[items copy] animated:NO];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initialize_DGInputAccessoryToolbar];
    }
    return self;
}

- (id)initWithTarget:(id)target prevAction:(SEL)prevAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction
{
    self = [super init];
    if (self)
    {
        actionTarget = target;
        prevActionSelector = prevAction;
        nextActionSelector = nextAction;
        doneActionSelector = doneAction;
        [self initialize_DGInputAccessoryToolbar];
    }
    return self;
}

- (void)setPreviousEnabled:(BOOL)previousEnabled
{
    if (prevActionSelector)
    {
        [segmented setEnabled:previousEnabled forSegmentAtIndex:0];
    }
}

- (BOOL)previousEnabled
{
    if (prevActionSelector)
    {
        return [segmented isEnabledForSegmentAtIndex:0];
    }
    return NO;
}

- (void)setNextEnabled:(BOOL)nextEnabled
{
    if (nextActionSelector)
    {
        [segmented setEnabled:nextEnabled forSegmentAtIndex:prevActionSelector?1:0];
    }
}

- (BOOL)nextEnabled
{
    if (nextActionSelector)
    {
        return [segmented isEnabledForSegmentAtIndex:prevActionSelector?1:0];
    }
    return NO;
}

- (void)segmentedControlChangedValued:(id)sender
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (segmented.selectedSegmentIndex == 0)
    {
        if (prevActionSelector)
        {
            [actionTarget performSelector:prevActionSelector withObject:segmented];
        }
        else
        {
            [actionTarget performSelector:nextActionSelector withObject:segmented];
        }
    }
    else
    {
        [actionTarget performSelector:nextActionSelector withObject:segmented];
    }
#pragma clang diagnostic pop
}

@end
