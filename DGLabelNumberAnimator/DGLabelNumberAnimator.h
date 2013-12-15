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