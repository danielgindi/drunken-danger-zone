//
//  DGLabelNumberAnimator.h
//  DGLabelNumberAnimator
//
//  Created by Daniel Cohen Gindi on 11/20/12.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//
//  This class allows animating of UILabels from a number to a number,
//    with animation curves and NSNumberFormatters
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

#import <Foundation/Foundation.h>

typedef enum _DGLabelNumberAnimatorAnimationType
{
    DGLabelNumberAnimatorAnimationTypeLinear,
    DGLabelNumberAnimatorAnimationTypeEaseIn,
    DGLabelNumberAnimatorAnimationTypeEaseOut,
    DGLabelNumberAnimatorAnimationTypeEaseInOut
} DGLabelNumberAnimatorAnimationType;

typedef NSString *(^DGLabelNumberAnimatorNumberFormatter)(NSNumber *number);

@interface DGLabelNumberAnimator : NSObject

// Instance methods

- (void)animate:(UILabel*)label from:(NSNumber *)from to:(NSNumber *)to withNumberFormatter:(NSNumberFormatter *)numberFormatter andDuration:(CFTimeInterval)duration andAnimationType:(DGLabelNumberAnimatorAnimationType)animationType completionBlock:(void(^)())completionBlock;
- (void)animate:(UILabel*)label from:(NSNumber *)from to:(NSNumber *)to withNumberFormatterBlock:(DGLabelNumberAnimatorNumberFormatter)numberFormatterBlock andDuration:(CFTimeInterval)duration andAnimationType:(DGLabelNumberAnimatorAnimationType)animationType completionBlock:(void(^)())completionBlock;

- (void)cancelAnimation;


// Class methods

+ (void)animate:(UILabel*)label from:(NSNumber *)from to:(NSNumber *)to withNumberFormatter:(NSNumberFormatter *)numberFormatter andDuration:(CFTimeInterval)duration andAnimationType:(DGLabelNumberAnimatorAnimationType)animationType completionBlock:(void(^)())completionBlock;
+ (void)animate:(UILabel*)label from:(NSNumber *)from to:(NSNumber *)to withNumberFormatterBlock:(DGLabelNumberAnimatorNumberFormatter)numberFormatterBlock andDuration:(CFTimeInterval)duration andAnimationType:(DGLabelNumberAnimatorAnimationType)animationType completionBlock:(void(^)())completionBlock;
+ (void)cancelAnimationForLabel:(UILabel*)label;

@end

@interface UILabel (DGLabelNumberAnimator)

- (void)animateNumberFrom:(NSNumber *)from to:(NSNumber *)to withNumberFormatter:(NSNumberFormatter *)numberFormatter andDuration:(CFTimeInterval)duration andAnimationType:(DGLabelNumberAnimatorAnimationType)animationType completionBlock:(void(^)())completionBlock;
- (void)animateNumberFrom:(NSNumber *)from to:(NSNumber *)to withNumberFormatterBlock:(DGLabelNumberAnimatorNumberFormatter)numberFormatterBlock andDuration:(CFTimeInterval)duration andAnimationType:(DGLabelNumberAnimatorAnimationType)animationType completionBlock:(void(^)())completionBlock;
- (void)cancelNumberAnimation;

@end