//
//  DGTwoSidedView.m
//  DGTwoSidedView
//
//  Created by Daniel Cohen Gindi on 11/17/12.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
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
