//
//  DGTwoSidedView.h
//  DGTwoSidedView
//
//  Created by Daniel Cohen Gindi on 11/17/12.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//
//  This is a view that accepts two CALayers, and places them on both sides.
//  Then you can use CAAnimation to show a flip rotation, like a card in a deck of cards.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface DGTwoSidedView : UIView

- (id)initWithFrontView:(CALayer *)frontLayer andBackView:(CALayer *)backLayer isFlipped:(BOOL)isFlipped;

@property (nonatomic, strong) CALayer *frontLayer;
@property (nonatomic, strong) CALayer *backLayer;
@property (nonatomic, assign) BOOL flipped;

@end
