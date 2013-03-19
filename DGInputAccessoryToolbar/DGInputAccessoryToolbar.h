//
//  DGInputAccessoryToolbar.h
//
//  Created by Daniel Cohen Gindi on 2/7/13.
//

#import <UIKit/UIKit.h>

@interface DGInputAccessoryToolbar : UIToolbar

- (id)initWithTarget:(id)target prevAction:(SEL)prevAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction;

@property (nonatomic, assign) BOOL previousEnabled;
@property (nonatomic, assign) BOOL nextEnabled;

@end
