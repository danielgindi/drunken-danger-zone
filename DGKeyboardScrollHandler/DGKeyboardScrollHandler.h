//
//  DGKeyboardScrollHandler.h
//  eyedo agent
//
//  Created by Daniel Cohen Gindi on 6/15/13.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import <Foundation/Foundation.h>

@interface DGKeyboardScrollHandler : NSObject <UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIViewController *viewController;
@property (nonatomic, assign) BOOL scrollToOriginalPositionAfterKeyboardHide;
@property (nonatomic, assign) CGSize staticScrollOffset;
@property (nonatomic, assign) BOOL suppressKeyboardEvents;
@property (nonatomic, assign) BOOL doNotResignForInteractive;
@property (nonatomic, strong, readonly) id currentFirstResponder;
@property (nonatomic, unsafe_unretained) id<UITextFieldDelegate> textFieldDelegate;
@property (nonatomic, unsafe_unretained) id<UITextViewDelegate> textViewDelegate;

- (id)initForViewController:(UIViewController*)viewController;
+ (id)keyboardScrollHandlerForViewController:(UIViewController*)viewController;

- (void)attachAllFieldDelegates; // Traverse the scrollView's hierarchy and find UITextFields and UITextViews to attach their delegates
- (void)dismissKeyboardIfPossible; // But you should actually use UIView's endEditing

// Events you need to propogate to DGKeyboardScrollHandler (of course after calling super)
- (void)viewDidAppear;
- (void)viewWillDisappear;
- (void)viewDidDisappear;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

// This you need to call when you KNOW that a view has become the first responder, and that view is NOT a textfield or textview that is delegated to DGKeyboardScrollHandler
- (void)viewBecameFirstResponder:(UIView*)firstResponder;

@end
