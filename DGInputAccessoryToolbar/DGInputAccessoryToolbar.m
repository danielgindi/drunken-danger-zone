//
//  DGInputAccessoryToolbar.m
//
//  Created by Daniel Cohen Gindi on 2/7/13.
//

#import "DGInputAccessoryToolbar.h"

@interface DGInputAccessoryToolbar ()
{
    id actionTarget;
    SEL prevActionSelector, nextActionSelector, doneActionSelector;
    UISegmentedControl * segmented;
    UIBarButtonItem * doneButton;
}
@end

@implementation DGInputAccessoryToolbar

- (void)initialize_DGInputAccessoryToolbar
{
    CGRect rect = self.frame;
    rect.size.height = 44.f;
    self.frame = rect;
    
    self.barStyle = UIBarStyleBlackTranslucent;
    self.translucent = YES;
    //self.tintColor = [UIColor darkGrayColor];
    
    NSString * prevString, * nextString;
    
    NSString * localeId = [NSBundle mainBundle].preferredLocalizations[0];
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
    
    NSMutableArray * items = [[NSMutableArray alloc] init];
    
    if (prevActionSelector || nextActionSelector)
    {
        segmented = [[UISegmentedControl alloc] initWithItems:((prevActionSelector&&nextActionSelector) ? @[prevString,nextString] : (prevActionSelector ? @[prevString] : @[nextString]))];
        [segmented addTarget:self action:@selector(segmentedControlChangedValued:) forControlEvents:UIControlEventValueChanged];
        segmented.segmentedControlStyle = UISegmentedControlStyleBar;
        segmented.tintColor = [UIColor darkGrayColor];
        segmented.momentary = YES;
        [items addObject:[[UIBarButtonItem alloc] initWithCustomView:segmented]];
    }
    
    UIBarButtonItem* flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
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
