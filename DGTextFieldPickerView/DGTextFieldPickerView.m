//
//  DGTextFieldPickerView.m
//  DGTextFieldPickerView
//
//  Created by Daniel Cohen Gindi on 4/18/12.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//

#import "DGTextFieldPickerView.h"
#import "DGTextFieldPickerCellView.h"

@interface DGTextFieldPickerInnerDelegate : NSObject <UITextFieldDelegate>
@property (nonatomic, unsafe_unretained) id parent;
@end

@interface DGTextFieldPickerView ()
{
    NSTimer *  _searchTimer;
    CGPoint _cursorOrigin;
    UIView * textLabelHideCursorView;
    UILabel * textLabelHideCursor;
    CGFloat requiredCellHeight;
}

@property (nonatomic, strong) DGTextFieldPickerInnerDelegate * _innerDelegate;

@end

@implementation DGTextFieldPickerView

static NSString* kEmpty = @"\x001";

static const CGFloat kSpacingYY1      = 1.f;
static const CGFloat kSpacingYY2      = 7.f;
static const CGFloat kSpacingY        = 8.f;
static const CGFloat kMinCursorWidth  = 50.f;

+ (BOOL)isRtl
{
    static BOOL isRtl = NO;
    static BOOL isRtlFound = NO;
    if (!isRtlFound)
    {
        isRtl = [NSLocale characterDirectionForLanguage:[NSBundle mainBundle].preferredLocalizations[0]] == NSLocaleLanguageDirectionRightToLeft;
        isRtlFound = YES;
    }
    return isRtl;
}

- (BOOL)isRtl
{
    return self.class.isRtl;
}

- (void)initialize_DGTextFieldPickerView
{
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.text = kEmpty;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    self.clearButtonMode = UITextFieldViewModeNever;
    self.returnKeyType = UIReturnKeyDone;
    self.enablesReturnKeyAutomatically = NO;
    _searchesAutomatically = YES;
    
    self._innerDelegate = [[DGTextFieldPickerInnerDelegate alloc] init];
    self._innerDelegate.parent = self;
    self.delegate = self._innerDelegate;
    
    _cellViews = [[NSMutableArray alloc] init];
    _lineCount = 1;
    _cursorOrigin = CGPointZero;
    
    _cellXSpacing = 8.f;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self initialize_DGTextFieldPickerView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) 
    {
        [self initialize_DGTextFieldPickerView];
    }
    return self;
}

- (void)setMinimumHeight:(CGFloat)minimumHeight
{
    if (_minimumHeight != minimumHeight)
    {
        _minimumHeight = minimumHeight;
        [self updateHeight];
    }
}

- (void)setCellXSpacing:(CGFloat)cellXSpacing
{
    if (_cellXSpacing != cellXSpacing)
    {
        _cellXSpacing = cellXSpacing;
        [self updateHeight];
    }
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    _contentInsets = contentInsets;
    [self setNeedsLayout];
}

- (void)textLabelHideCursorTapped:(UITapGestureRecognizer*)recognizer
{
    self.selectedCell = nil;
}

#pragma mark - Cells layout

- (CGFloat)layoutCells
{
    CGFloat lineHeight = self.font.lineHeight;
    CGFloat lineIncrement = lineHeight + kSpacingY;
    CGRect rcTextArea = UIEdgeInsetsInsetRect([super editingRectForBounds:self.bounds], _contentInsets);
    
    _cursorOrigin.x = rcTextArea.origin.x;
    _cursorOrigin.y = rcTextArea.origin.y;
    _lineCount = 1;
    
    if (self.frame.size.width) 
    {
        for (DGTextFieldPickerCellView* cell in _cellViews)
        {
            [cell sizeToFit];
            
            if (_cursorOrigin.x + cell.frame.size.width >= rcTextArea.origin.x + rcTextArea.size.width && _cursorOrigin.x > rcTextArea.origin.x)
            {
                _cursorOrigin.x = rcTextArea.origin.x;
                _cursorOrigin.y += lineIncrement;
                ++_lineCount;
            }
            
            cell.frame = CGRectMake(_cursorOrigin.x,
                                    _cursorOrigin.y + kSpacingYY1,
                                    cell.frame.size.width,
                                    cell.frame.size.height);
            _cursorOrigin.x += cell.frame.size.width + _cellXSpacing;
        }
        
        CGFloat remainingWidth = rcTextArea.size.width - (_cursorOrigin.x - rcTextArea.origin.x);
        if (remainingWidth < kMinCursorWidth)
        {
            _cursorOrigin.x = rcTextArea.origin.x;
            _cursorOrigin.y += lineIncrement;
            ++_lineCount;
        }
    }
    
    return _cursorOrigin.y + lineHeight + kSpacingYY1 + kSpacingYY2 + _contentInsets.bottom;
}

- (void)updateHeight 
{
    CGFloat previousHeight = self.frame.size.height;
    requiredCellHeight = [self layoutCells];
    requiredCellHeight = MAX(requiredCellHeight, _minimumHeight);
    if (previousHeight && requiredCellHeight != previousHeight) 
    {
        [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, requiredCellHeight);
        } completion:^(BOOL finished) {
            
        }];
        
        [self setNeedsDisplay];
        
        if ([(id)_searchDelegate respondsToSelector:@selector(textFieldPickerViewDidResize:)]) 
        {
            [_searchDelegate textFieldPickerViewDidResize:self];
        }
        
        [self scrollToVisibleLine:YES];
    }
}

- (CGFloat)topOfLine:(int)lineNumber
{
    if (lineNumber == 0) 
    {
        return 0;
    } 
    else 
    {
        CGFloat lineHeight = self.font.lineHeight;
        return _contentInsets.top + (lineNumber-1 * lineHeight + kSpacingY);
    }
}

- (CGFloat)centerOfLine:(int)lineNumber 
{
    CGFloat lineTop = [self topOfLine:lineNumber];
    CGFloat lineHeight = self.font.lineHeight;
    return lineTop + floor(lineHeight/2);
}

- (void)selectLastCell 
{
    self.selectedCell = [_cellViews objectAtIndex:_cellViews.count-1];
}

- (NSString*)labelForObject:(id)object 
{
    NSString* label = nil;
    if ([(id)_searchDelegate respondsToSelector:@selector(textFieldPickerView:labelForObject:)]) 
    {
        label = [_searchDelegate textFieldPickerView:self labelForObject:object];
    }
    return label ? label : [NSString stringWithFormat:@"%@", object];
}

- (NSString*)searchText 
{
    if (!self.hasText) 
    {
        return @"";
        
    } 
    else 
    {
        return [[self.text stringByReplacingOccurrencesOfString:kEmpty withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
}

#pragma mark - UIView

- (void)layoutSubviews 
{
    if (_searchDelegate) 
    {
        requiredCellHeight = [self layoutCells];
        requiredCellHeight = MAX(requiredCellHeight, _minimumHeight);
    } 
    else 
    {
        CGRect rcTextArea = UIEdgeInsetsInsetRect([super editingRectForBounds:self.bounds], _contentInsets);
        _cursorOrigin.x = rcTextArea.origin.x;
        _cursorOrigin.y = rcTextArea.origin.y;
    }
    
    if (_searchDelegate && _selectedCell)
    {
        // Hide the cursor while a cell is selected
        if (!textLabelHideCursor)
        {
            textLabelHideCursorView = [[UIView alloc] init];
            textLabelHideCursorView.backgroundColor = [UIColor clearColor];
            textLabelHideCursorView.clipsToBounds = YES;
            
            textLabelHideCursor = [[UILabel alloc] init];
            textLabelHideCursor.backgroundColor = [UIColor clearColor];
            textLabelHideCursor.userInteractionEnabled = YES;
            
            UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textLabelHideCursorTapped:)];
            [textLabelHideCursor addGestureRecognizer:tapGestureRecognizer];
            
            [textLabelHideCursorView addSubview:textLabelHideCursor];
            [self addSubview:textLabelHideCursorView];
        }
        textLabelHideCursor.textAlignment = self.textAlignment;
        textLabelHideCursor.text = self.text;
        textLabelHideCursor.textColor = self.textColor;
        textLabelHideCursor.font = self.font;
        textLabelHideCursorView.frame = [self realTextRectForBounds:self.bounds];
        CGRect rc = textLabelHideCursorView.frame;
        rc.origin.x = 0.f;
        rc.origin.y = 0.f;
        rc.size.width += 100.f;
        textLabelHideCursor.frame = rc;
        textLabelHideCursorView.hidden = NO;
    }
    else
    {
        textLabelHideCursorView.hidden = YES;
    }
    
    [super layoutSubviews];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    [self layoutIfNeeded];
    return CGSizeMake(size.width, requiredCellHeight);
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event 
{
    [super touchesBegan:touches withEvent:event];
    
    if (_searchDelegate) 
    {
        UITouch* touch = [touches anyObject];
        if (touch.view == self) 
        {
            self.selectedCell = nil;
        } 
        else 
        {
            if ([touch.view isKindOfClass:[DGTextFieldPickerCellView class]])
            {
                self.selectedCell = (DGTextFieldPickerCellView*)touch.view;
                [self becomeFirstResponder];
            }
        }
    }
}


#pragma mark - UITextField

- (void)drawPlaceholderInRect:(CGRect)rect
{
    if (_placeholderColor)
    {
        [_placeholderColor setFill];
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
        [self.placeholder drawInRect:rect withFont:self.font lineBreakMode:NSLineBreakByTruncatingTail alignment:self.textAlignment];
#else
        [self.placeholder drawInRect:rect withFont:self.font lineBreakMode:UILineBreakModeTailTruncation alignment:self.textAlignment];
#endif
    }
    else
    {
        [super drawPlaceholderInRect:rect];
    }
}

- (CGRect)realTextRectForBounds:(CGRect)bounds
{
    CGRect frame = UIEdgeInsetsInsetRect([super textRectForBounds:bounds], _contentInsets);
    
    CGFloat xDelta = _cursorOrigin.x - frame.origin.x;
    CGFloat yDelta = _cursorOrigin.y - frame.origin.y;
    frame.origin.x += xDelta;
    frame.size.width -= xDelta;
    frame.origin.y += yDelta;
    frame.size.height -= yDelta;
    
    return frame;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return [self realTextRectForBounds:bounds];
}

- (CGRect)editingRectForBounds:(CGRect)bounds 
{
    if (_searchDelegate && _selectedCell)
    {
        // Hide the cursor while a cell is selected
        return CGRectMake(-10, 0, 0, 0);
    }
    else
    {
        return [self realTextRectForBounds:bounds];
    }
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds 
{
    return [self realTextRectForBounds:bounds];
}

#pragma mark - Cells stuff

- (NSArray*)cells 
{
    NSMutableArray* cells = [NSMutableArray array];
    for (DGTextFieldPickerCellView* cellView in _cellViews)
    {
        [cells addObject:cellView.object ? cellView.object : [NSNull null]];
    }
    return cells;
}

- (void)addCellWithObject:(id)object 
{
    DGTextFieldPickerCellView* cell = [[DGTextFieldPickerCellView alloc] init];
    
    NSString* label = [self labelForObject:object];
    
    cell.object = object;
    cell.label = label;
    cell.font = self.font;
    if (_cellTextColor) cell.textColor = _cellTextColor;
    if (_cellBgColor1) cell.bgColor1 = _cellBgColor1;
    if (_cellBgColor2) cell.bgColor2 = _cellBgColor2;
    if (_cellBorderColor1) cell.borderColor1 = _cellBorderColor1;
    if (_cellBorderColor2) cell.borderColor2 = _cellBorderColor2;
    if (_cellHighlightedTextColor) cell.highlightedTextColor = _cellHighlightedTextColor;
    if (_cellHighlightedBgColor1) cell.highlightedBgColor1 = _cellHighlightedBgColor1;
    if (_cellHighlightedBgColor2) cell.highlightedBgColor2 = _cellHighlightedBgColor2;
    if (_cellHighlightedBorderColor1) cell.highlightedBorderColor1 = _cellHighlightedBorderColor1;
    if (_cellHighlightedBorderColor2) cell.highlightedBorderColor2 = _cellHighlightedBorderColor2;
    [((NSMutableArray*)_cellViews) addObject:cell];
    [self addSubview:cell];
    
    // Reset text so the cursor moves to be at the end of the cellViews
    self.text = kEmpty;
    
    if ([(id)_searchDelegate respondsToSelector:@selector(textFieldPickerView:didAddCellAtIndex:)]) 
    {
        [_searchDelegate textFieldPickerView:self didAddCellAtIndex:(_cellViews.count-1)];
    }
}

- (void)removeCellWithObject:(id)object 
{
    for (int i = 0; i < _cellViews.count; ++i) 
    {
        DGTextFieldPickerCellView* cell = [_cellViews objectAtIndex:i];
        if (cell.object == object) 
        {
            [((NSMutableArray*)_cellViews) removeObjectAtIndex:i];
            [cell removeFromSuperview];
            
            if (cell == _selectedCell)
            {
                self.selectedCell = nil;
            }
            
            if ([(id)_searchDelegate respondsToSelector:@selector(textFieldPickerView:didRemoveCellAtIndex:)]) 
            {
                [_searchDelegate textFieldPickerView:self didRemoveCellAtIndex:i];
            }
            break;
        }
    }
    
    // Reset text so the cursor oves to be at the end of the cellViews
    self.text = self.text;
}

- (void)removeAllCells 
{
    while (_cellViews.count) 
    {
        DGTextFieldPickerCellView* cell = [_cellViews objectAtIndex:0];
        [cell removeFromSuperview];
        [((NSMutableArray*)_cellViews) removeObjectAtIndex:0];
    }
    
    self.selectedCell = nil;
}

- (void)setSelectedCell:(DGTextFieldPickerCellView*)cell
{
    if (_selectedCell) 
    {
        _selectedCell.selected = NO;
    }
    
    _selectedCell = cell;
    
    if (_selectedCell) 
    {
        _selectedCell.selected = YES;
    }
    
    [self setNeedsLayout];
}

- (void)removeSelectedCell 
{
    if (_selectedCell) 
    {
        [self removeCellWithObject:_selectedCell.object];
        self.selectedCell = nil;
        
        self.text = kEmpty;
    }
}

- (void)scrollToVisibleLine:(BOOL)animated 
{
    if (self.editing) 
    {
        UIScrollView * scrollView = (self.superview && [self.superview isKindOfClass:[UIScrollView class]]) ? (UIScrollView*)self.superview : nil;
        if (scrollView) 
        {
            [scrollView setContentOffset:CGPointMake(0, self.frame.origin.y) animated:animated];
        }
    }
}

- (void)scrollToEditingLine:(BOOL)animated 
{
    UIScrollView * scrollView = (self.superview && [self.superview isKindOfClass:[UIScrollView class]]) ? (UIScrollView*)self.superview : nil;
    if (scrollView) 
    {
        CGFloat offset = _lineCount == 1 ? 0 : [self topOfLine:_lineCount-1];
        [scrollView setContentOffset:CGPointMake(0, self.frame.origin.y+offset) animated:animated];
    }
}

- (void)autoSearch 
{
    if (_searchesAutomatically && self.hasText) 
    {
        [self search];
    }
}

- (void)dispatchUpdate:(NSTimer*)timer 
{
    _searchTimer = nil;
    [self autoSearch];
}

- (void)delayedUpdate 
{
    [_searchTimer invalidate];
    _searchTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self
                                                  selector:@selector(dispatchUpdate:) userInfo:nil repeats:NO];
}

- (BOOL)hasSearchResults 
{
    if (_searchDelegate)
    {
        return [_searchDelegate textFieldPickerViewHasSearchResults:self];
    }
    return YES;
}

- (void)setText:(NSString*)text 
{
    if (_searchDelegate) 
    {
        [self updateHeight];
    }
    if (text.length == 0)
    {
        text = kEmpty;
    }
    else if (![text hasPrefix:kEmpty])
    {
        text = [kEmpty stringByAppendingString:text];
    }
    [super setText:text];
    [self autoSearch];
}

- (void)setSearchesAutomatically:(BOOL)searchesAutomatically 
{
    _searchesAutomatically = searchesAutomatically;
    if (searchesAutomatically) 
    {
        self.returnKeyType = UIReturnKeyDone;
        self.enablesReturnKeyAutomatically = NO;
        
    } 
    else 
    {
        self.returnKeyType = UIReturnKeySearch;
        self.enablesReturnKeyAutomatically = YES;
    }
}

- (BOOL)hasText 
{
    return self.text.length && ![self.text isEqualToString:kEmpty];
}

- (void)search 
{
    if (_searchDelegate) 
    {
        [self showSearchResults:[_searchDelegate textFieldPickerView:self search:self.searchText]];
    }
}

- (void)showSearchResults:(BOOL)show 
{
    if (_searchDelegate) 
    {    
        [_searchDelegate textFieldPickerView:self showSearchTable:show];
    }
    if (show) 
    {
        [self scrollToEditingLine:YES];
    } 
    else 
    {
        [self scrollToVisibleLine:YES];
    }
}

#pragma mark - Cell styling

- (void)setCellTextColor:(UIColor *)cellTextColor
{
    _cellTextColor = cellTextColor;
    for (DGTextFieldPickerCellView * cell in _cellViews)
    {
        cell.textColor = _cellTextColor;
    }
}

- (void)setCellBgColor1:(UIColor *)cellBgColor1
{
    _cellBgColor1 = cellBgColor1;
    for (DGTextFieldPickerCellView * cell in _cellViews)
    {
        cell.bgColor1 = _cellBgColor1;
    }
}

- (void)setCellBgColor2:(UIColor *)cellBgColor2
{
    _cellBgColor2 = cellBgColor2;
    for (DGTextFieldPickerCellView * cell in _cellViews)
    {
        cell.bgColor2 = _cellBgColor2;
    }
}

- (void)setCellBorderColor1:(UIColor *)cellBorderColor1
{
    _cellBorderColor1 = cellBorderColor1;
    for (DGTextFieldPickerCellView * cell in _cellViews)
    {
        cell.borderColor1 = cellBorderColor1;
    }
}

- (void)setCellBorderColor2:(UIColor *)cellBorderColor2
{
    _cellBorderColor2 = cellBorderColor2;
    for (DGTextFieldPickerCellView * cell in _cellViews)
    {
        cell.borderColor2 = cellBorderColor2;
    }
}

- (void)setCellHighlightedTextColor:(UIColor *)cellHighlightedTextColor
{
    _cellHighlightedTextColor = cellHighlightedTextColor;
    for (DGTextFieldPickerCellView * cell in _cellViews)
    {
        cell.highlightedTextColor = _cellHighlightedTextColor;
    }
}

- (void)setCellHighlightedBgColor1:(UIColor *)cellHighlightedBgColor1
{
    _cellHighlightedBgColor1 = cellHighlightedBgColor1;
    for (DGTextFieldPickerCellView * cell in _cellViews)
    {
        cell.highlightedBgColor1 = _cellHighlightedBgColor1;
    }
}

- (void)setCellHighlightedBgColor2:(UIColor *)cellHighlightedBgColor2
{
    _cellHighlightedBgColor2 = cellHighlightedBgColor2;
    for (DGTextFieldPickerCellView * cell in _cellViews)
    {
        cell.highlightedBgColor2 = _cellHighlightedBgColor2;
    }
}

- (void)setCellHighlightedBorderColor1:(UIColor *)cellHighlightedBorderColor1
{
    _cellHighlightedBorderColor1 = cellHighlightedBorderColor1;
    for (DGTextFieldPickerCellView * cell in _cellViews)
    {
        cell.highlightedBorderColor1 = _cellHighlightedBorderColor1;
    }
}

- (void)setCellHighlightedBorderColor2:(UIColor *)cellHighlightedBorderColor2
{
    _cellHighlightedBorderColor2 = cellHighlightedBorderColor2;
    for (DGTextFieldPickerCellView * cell in _cellViews)
    {
        cell.highlightedBorderColor2 = _cellHighlightedBorderColor2;
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField*)textField 
{
    if (_searchDelegate) 
    {
        if (self.hasText && self.hasSearchResults) 
        {
            [self showSearchResults:YES];
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField*)textField 
{
    if (_selectedCell) 
    {
        self.selectedCell = nil;
    }
    if (_searchDelegate) 
    {
        [self showSearchResults:NO];
    }
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string 
{
    if (!string.length)
    {
        if (!self.hasText && !self.selectedCell && self.cells.count)
        {
            [self selectLastCell];
            return NO;
        }
        else if (self.selectedCell)
        {
            [self removeSelectedCell];
            [self delayedUpdate];
            return NO;
        }
        else if (self.hasText)
        {
            NSString * finalText = [self.text stringByReplacingCharactersInRange:range withString:string];
            [self showSearchResults:NO];
            if (!finalText.length)
            {
                self.text = kEmpty;
                return NO;
            }
        }
    }
    else
    {
        if (!self.hasText && self.selectedCell)
        {
            [self removeSelectedCell];
            [self delayedUpdate];
        }
        else
        {
            [self delayedUpdate];
            
            if (self.selectedCell)
            {
                [self removeSelectedCell];
                self.text = string;
                
                UITextPosition *startPosition = [self positionFromPosition:self.beginningOfDocument offset:self.text.length];
                UITextPosition *endPosition = [self positionFromPosition:self.beginningOfDocument offset:self.text.length];
                UITextRange *selection = [self textRangeFromPosition:startPosition toPosition:endPosition];
                self.selectedTextRange = selection;
                
                return NO;
            }
        }
    }
    
    if (textLabelHideCursorView && !textLabelHideCursorView.hidden)
    {
        NSString * newText = [self.text stringByReplacingCharactersInRange:range withString:string];
        textLabelHideCursor.text = newText;
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField*)textField 
{
    if (self.selectedCell)
    {
        [self removeSelectedCell];
    }
    [self delayedUpdate];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if (!self.searchesAutomatically) 
    {
        [self search];
    } 
    else 
    {
        [_searchDelegate textFieldPickerView:self showSearchTable:NO];
        if (self.hasText && [((id)_searchDelegate) respondsToSelector:@selector(textFieldPickerView:returnRequestedWithText:)])
        {
            [_searchDelegate textFieldPickerView:self returnRequestedWithText:self.searchText];
        }
    }
    return YES;
}

@end

#pragma mark - DGTextFieldPickerInnerDelegate

@implementation DGTextFieldPickerInnerDelegate

@synthesize parent;

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField*)textField 
{
    if ([parent respondsToSelector:@selector(textFieldDidBeginEditing:)])
    {
        [parent performSelector:@selector(textFieldDidBeginEditing:) withObject:textField];
    }
}

- (void)textFieldDidEndEditing:(UITextField*)textField 
{
    if ([parent respondsToSelector:@selector(textFieldDidEndEditing:)])
    {
        [parent performSelector:@selector(textFieldDidEndEditing:) withObject:textField];
    }
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string 
{
    if ([parent respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
    {
        return [parent textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField*)textField 
{
    if ([parent respondsToSelector:@selector(textFieldShouldClear:)])
    {
        return (BOOL)[parent performSelector:@selector(textFieldShouldClear:) withObject:textField];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if ([parent respondsToSelector:@selector(textFieldShouldReturn:)])
    {
        return (BOOL)[parent performSelector:@selector(textFieldShouldReturn:) withObject:textField];
    }
    return YES;
}

@end
