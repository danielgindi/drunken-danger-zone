//
//  DGLabelNumberAnimator.m
//  DGLabelNumberAnimator
//
//  Created by Daniel Cohen Gindi on 11/20/12.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
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

#import "DGLabelNumberAnimator.h"
#import <QuartzCore/QuartzCore.h>

typedef enum _DGLabelNumberAnimatorNumberType
{
    DGLabelNumberAnimatorNumberTypeDefault,
    DGLabelNumberAnimatorNumberTypeDouble,
    DGLabelNumberAnimatorNumberTypeFloat,
    DGLabelNumberAnimatorNumberTypeLongLong
} DGLabelNumberAnimatorNumberType;

@interface DGLabelNumberAnimator ()
{
    UILabel *_label;
    NSObject *_numberFormatter;
    NSNumber *_from;
    NSNumber *_to;
    CADisplayLink *_displayLink;
    CFTimeInterval startTime;
    CFTimeInterval _duration;
    DGLabelNumberAnimatorNumberType _numberType;
    DGLabelNumberAnimatorAnimationType _animationType;
    void (^_completionBlock)();
}

@end

@implementation DGLabelNumberAnimator

- (void)animate:(UILabel *)label from:(NSNumber *)from to:(NSNumber *)to withNumberFormatter:(NSNumberFormatter *)numberFormatter andDuration:(CFTimeInterval)duration andAnimationType:(DGLabelNumberAnimatorAnimationType)animationType completionBlock:(void(^)())completionBlock
{
    [self cancelAnimation];
    
    _label = label;
    _from = from;
    _to = to;
    _numberFormatter = numberFormatter;
    _duration = duration;
    _animationType = animationType;
    _completionBlock = [completionBlock copy];
    
    if (strcmp([_from objCType], @encode(double)) == 0)
    {
        _numberType = DGLabelNumberAnimatorNumberTypeDouble;
    }
    else if (strcmp([_from objCType], @encode(float)) == 0)
    {
        _numberType = DGLabelNumberAnimatorNumberTypeFloat;
    }
    else if (strcmp([_from objCType], @encode(__INT64_TYPE__)) == 0)
    {
        _numberType = DGLabelNumberAnimatorNumberTypeLongLong;
    }
    else
    {
        _numberType = DGLabelNumberAnimatorNumberTypeDefault;
    }
    
    _label.text = _numberFormatter ? ([_numberFormatter isKindOfClass:NSNumberFormatter.class] ? [(NSNumberFormatter *)_numberFormatter stringFromNumber:_from] : ((DGLabelNumberAnimatorNumberFormatter)_numberFormatter)(_from)) : [_from stringValue];
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animationStep:)];
    
    startTime = CACurrentMediaTime();
    
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)animate:(UILabel *)label from:(NSNumber *)from to:(NSNumber *)to withNumberFormatterBlock:(DGLabelNumberAnimatorNumberFormatter)numberFormatterBlock andDuration:(CFTimeInterval)duration andAnimationType:(DGLabelNumberAnimatorAnimationType)animationType completionBlock:(void(^)())completionBlock
{
    [self animate:label from:from to:to withNumberFormatterBlock:(id)numberFormatterBlock andDuration:duration andAnimationType:animationType completionBlock:completionBlock];
}

- (void)cancelAnimation
{
    [_displayLink invalidate];
    _displayLink = nil;
}

- (void)animationStep:(CADisplayLink *)displayLink
{
    double dt = ([displayLink timestamp] - startTime) / _duration;
    if (dt >= _duration)
    {
        _label.text = _numberFormatter ? ([_numberFormatter isKindOfClass:NSNumberFormatter.class] ? [(NSNumberFormatter *)_numberFormatter stringFromNumber:_to] : ((DGLabelNumberAnimatorNumberFormatter)_numberFormatter)(_to)) : [_to stringValue];
        
        [displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        
        if (_completionBlock)
        {
            _completionBlock();
        }
        
        return;
    }
    
    if (_animationType == DGLabelNumberAnimatorAnimationTypeEaseIn)
    {
        dt = -(cos(dt * (M_PI / 2.0))) + 1.0;
    }
    else if (_animationType == DGLabelNumberAnimatorAnimationTypeEaseOut)
    {
        dt = sin(dt * (M_PI / 2.0));
    }
    else if (_animationType == DGLabelNumberAnimatorAnimationTypeEaseInOut)
    {
        dt = (-cos(dt * M_PI) / 2.0) + 0.5;
    }
    
    if (_numberType == DGLabelNumberAnimatorNumberTypeDouble)
    {
        double current = ([_to doubleValue] - [_from doubleValue]) * dt + [_from doubleValue];
        _label.text = _numberFormatter ? ([_numberFormatter isKindOfClass:NSNumberFormatter.class] ? [(NSNumberFormatter *)_numberFormatter stringFromNumber:@(current)] : ((DGLabelNumberAnimatorNumberFormatter)_numberFormatter)(@(current))) : [@(current) stringValue];
    }
    else if (_numberType == DGLabelNumberAnimatorNumberTypeFloat)
    {
        float current = ([_to floatValue] - [_from floatValue]) * dt + [_from floatValue];
        _label.text = _numberFormatter ? ([_numberFormatter isKindOfClass:NSNumberFormatter.class] ? [(NSNumberFormatter *)_numberFormatter stringFromNumber:@(current)] : ((DGLabelNumberAnimatorNumberFormatter)_numberFormatter)(@(current))) : [@(current) stringValue];
    }
    else if (_numberType == DGLabelNumberAnimatorNumberTypeLongLong)
    {
        __INT64_TYPE__ current = ([_to longLongValue] - [_from longLongValue]) * dt + [_from longLongValue];
        _label.text = _numberFormatter ? ([_numberFormatter isKindOfClass:NSNumberFormatter.class] ? [(NSNumberFormatter *)_numberFormatter stringFromNumber:@(current)] : ((DGLabelNumberAnimatorNumberFormatter)_numberFormatter)(@(current))) : [@(current) stringValue];
    }
    else
    {
        int current = ([_to intValue] - [_from intValue]) * dt + [_from intValue];
        _label.text = _numberFormatter ? ([_numberFormatter isKindOfClass:NSNumberFormatter.class] ? [(NSNumberFormatter *)_numberFormatter stringFromNumber:@(current)] : ((DGLabelNumberAnimatorNumberFormatter)_numberFormatter)(@(current))) : [@(current) stringValue];
    }
}

static NSMutableArray * arrayOfLabels = nil;
static NSMutableArray * arrayOfAnims = nil;

+ (void)animate:(UILabel *)label from:(NSNumber *)from to:(NSNumber *)to withNumberFormatter:(NSNumberFormatter *)numberFormatter andDuration:(CFTimeInterval)duration andAnimationType:(DGLabelNumberAnimatorAnimationType)animationType completionBlock:(void(^)())completionBlock
{
    if (!label) return;
    if (completionBlock)
    {
        // If it's not "copied" yet - copy. If it is, it will just be retained.
        completionBlock = [completionBlock copy];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^(void){
        
        if (arrayOfLabels == nil)
        {
            arrayOfLabels = [[NSMutableArray alloc] init];
            arrayOfAnims = [[NSMutableArray alloc] init];
        }
        else
        {
            NSUInteger idx = [arrayOfLabels indexOfObject:label];
            if (idx != NSNotFound)
            {
                [((DGLabelNumberAnimator*)arrayOfAnims[idx]) cancelAnimation];
                [arrayOfLabels removeObjectAtIndex:idx];
                [arrayOfAnims removeObjectAtIndex:idx];
            }
        }
        
        DGLabelNumberAnimator * animator = [[DGLabelNumberAnimator alloc] init];
        
        [arrayOfLabels addObject:label];
        [arrayOfAnims addObject:animator];
        
        [animator animate:label from:from to:to withNumberFormatter:numberFormatter andDuration:duration andAnimationType:animationType completionBlock:^{
            
            NSInteger idx = [arrayOfAnims indexOfObject:animator];
            if (idx != NSNotFound)
            {
                [arrayOfLabels removeObjectAtIndex:idx];
                [arrayOfAnims removeObjectAtIndex:idx];
                
                if (completionBlock)
                {
                    completionBlock();
                }
            }
            
        }];
        
    });
}

+ (void)animate:(UILabel *)label from:(NSNumber *)from to:(NSNumber *)to withNumberFormatterBlock:(DGLabelNumberAnimatorNumberFormatter)numberFormatterBlock andDuration:(CFTimeInterval)duration andAnimationType:(DGLabelNumberAnimatorAnimationType)animationType completionBlock:(void(^)())completionBlock
{
    [self animate:label from:from to:to withNumberFormatter:(id)numberFormatterBlock andDuration:duration andAnimationType:animationType completionBlock:completionBlock];
}

+ (void)cancelAnimationForLabel:(UILabel *)label
{
    if (!arrayOfLabels) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^(void){
        
        NSUInteger idx = [arrayOfLabels indexOfObject:label];
        if (idx != NSNotFound)
        {
            [((DGLabelNumberAnimator*)arrayOfAnims[idx]) cancelAnimation];
            [arrayOfLabels removeObjectAtIndex:idx];
            [arrayOfAnims removeObjectAtIndex:idx];
        }
        
    });
}

@end

@implementation UILabel (DGLabelNumberAnimator)

- (void)animateNumberFrom:(NSNumber *)from to:(NSNumber *)to withNumberFormatter:(NSNumberFormatter *)numberFormatter andDuration:(CFTimeInterval)duration andAnimationType:(DGLabelNumberAnimatorAnimationType)animationType completionBlock:(void(^)())completionBlock
{
    [DGLabelNumberAnimator animate:self from:from to:to withNumberFormatter:numberFormatter andDuration:duration andAnimationType:animationType completionBlock:completionBlock];
}

- (void)animateNumberFrom:(NSNumber *)from to:(NSNumber *)to withNumberFormatterBlock:(DGLabelNumberAnimatorNumberFormatter)numberFormatterBlock andDuration:(CFTimeInterval)duration andAnimationType:(DGLabelNumberAnimatorAnimationType)animationType completionBlock:(void(^)())completionBlock
{
    [DGLabelNumberAnimator animate:self from:from to:to withNumberFormatter:(id)numberFormatterBlock andDuration:duration andAnimationType:animationType completionBlock:completionBlock];
}

- (void)cancelNumberAnimation
{
    [DGLabelNumberAnimator cancelAnimationForLabel:self];
}

@end
