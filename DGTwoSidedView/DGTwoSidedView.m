//
//  DGTwoSidedView.m
//  DGTwoSidedView
//
//  Created by Daniel Cohen Gindi on 11/17/12.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGTwoSidedView.h"
#import <QuartzCore/QuartzCore.h>

@implementation DGTwoSidedView

#define CATransform3DFaceDown (CATransform3D) { \
        -1, 0, 0, 0, \
        0, 1, 0, 0, \
        0, 0, -1, 0, \
        0, 0, 0, 1 }

- (id)initWithFrontView:(CALayer *)frontLayer andBackView:(CALayer *)backLayer isFlipped:(BOOL)isFlipped
{
    self = [super init];
    if (self)
    {
        _flipped = isFlipped;
        
        _frontLayer = frontLayer;
        _backLayer = backLayer;
        
        if (_flipped)
        {
            _frontLayer.transform = CATransform3DFaceDown;
            _backLayer.transform = CATransform3DIdentity;
        }
        else
        {
            _frontLayer.transform = CATransform3DIdentity;
            _backLayer.transform = CATransform3DFaceDown;
        }
        
        _frontLayer.doubleSided = NO;
        _backLayer.doubleSided = NO;
        
        [self.layer addSublayer:_frontLayer];
        [self.layer addSublayer:_backLayer];
        
        self.frame = _frontLayer.frame;
    }
    return self;
}

- (void)setFrontLayer:(CALayer *)frontLayer
{
    [frontLayer removeFromSuperlayer];
    if (_flipped)
    {
        frontLayer.transform = CATransform3DFaceDown;
    }
    else
    {
        frontLayer.transform = CATransform3DIdentity;
    }
    frontLayer.doubleSided = NO;
    [self.layer addSublayer:frontLayer];
    _frontLayer = frontLayer;
}

- (void)setBackLayer:(CALayer *)backLayer
{
    [backLayer removeFromSuperlayer];
    if (_flipped)
    {
        backLayer.transform = CATransform3DIdentity;
    }
    else
    {
        backLayer.transform = CATransform3DFaceDown;
    }
    backLayer.doubleSided = NO;
    [self.layer addSublayer:backLayer];
    _backLayer = backLayer;
}

- (void)setFlipped:(BOOL)flipped
{
    _flipped = flipped;
    if (_flipped)
    {
        _frontLayer.transform = CATransform3DFaceDown;
        _backLayer.transform = CATransform3DIdentity;
    }
    else
    {
        _frontLayer.transform = CATransform3DIdentity;
        _backLayer.transform = CATransform3DFaceDown;
    }
}

@end
